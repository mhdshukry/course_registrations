<?php

namespace App\Services;

use App\Models\CourseOffering;
use App\Models\Notification;
use App\Models\RegistrationCourse;
use App\Models\Student;
use App\Models\WaitingList;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class WaitingListService
{
    /**
     * Add student to waiting list for a full course offering
     */
    public function joinWaitingList(Student $student, CourseOffering $offering): WaitingList
    {
        return DB::transaction(function () use ($student, $offering) {
            // Check if already in waiting list
            $existing = WaitingList::where('offering_id', $offering->offering_id)
                ->where('student_id', $student->student_id)
                ->first();

            // Next queue position calculation helper
            $maxPosition = WaitingList::where('offering_id', $offering->offering_id)
                ->where('status', 'WAITING')
                ->max('position') ?? 0;

            if ($existing) {
                if (in_array($existing->status, ['WAITING', 'PROMOTED'])) {
                    return $existing;
                }

                // If previously cancelled or expired, re-activate and place at end of queue
                $existing->update([
                    'status' => 'WAITING',
                    'position' => $maxPosition + 1,
                    'joined_at' => now(),
                ]);

                return $existing;
            }

            return WaitingList::create([
                'waiting_list_id' => 'wl_' . Str::random(12),
                'offering_id' => $offering->offering_id,
                'student_id' => $student->student_id,
                'position' => $maxPosition + 1,
                'status' => 'WAITING',
                'joined_at' => now(),
            ]);
        });
    }

    /**
     * Promote the next student in the queue when a seat becomes available
     */
    public function processSeatVacated(CourseOffering $offering): ?WaitingList
    {
        return DB::transaction(function () use ($offering) {
            // Check if there is still capacity
            if ($offering->registration_count >= $offering->capacity) {
                return null;
            }

            // Find next waiting student
            $nextWaiting = WaitingList::where('offering_id', $offering->offering_id)
                ->where('status', 'WAITING')
                ->orderBy('position', 'asc')
                ->first();

            if (!$nextWaiting) {
                return null;
            }

            // Promote
            $nextWaiting->update([
                'status' => 'PROMOTED',
            ]);

            // Re-order remaining waiting students
            WaitingList::where('offering_id', $offering->offering_id)
                ->where('status', 'WAITING')
                ->where('position', '>', $nextWaiting->position)
                ->decrement('position');

            // Send notification to promoted student
            $student = $nextWaiting->student;
            if ($student && $student->user_id) {
                Notification::create([
                    'notification_id' => 'notif_' . Str::random(12),
                    'user_id' => $student->user_id,
                    'notification_type' => 'WAITING_LIST_SEAT',
                    'title' => 'Seat Available in ' . ($offering->course->course_code ?? 'Course'),
                    'message' => 'A seat became available for ' . ($offering->course->course_title ?? 'your course') . '. You have been promoted from the waiting list!',
                    'is_read' => false,
                    'sent_at' => now(),
                ]);
            }

            return $nextWaiting;
        });
    }

    /**
     * Claim a promoted seat from the waiting list and enroll into student's active registration
     */
    public function claimPromotedSeat(Student $student, string $waitingListId): array
    {
        return DB::transaction(function () use ($student, $waitingListId) {
            $entry = WaitingList::with('offering.course')
                ->where('waiting_list_id', $waitingListId)
                ->where('student_id', $student->student_id)
                ->firstOrFail();

            if ($entry->status !== 'PROMOTED') {
                throw new \Exception("Cannot claim seat: Queue entry is not currently promoted (status: {$entry->status}).");
            }

            $offering = CourseOffering::where('offering_id', $entry->offering_id)->lockForUpdate()->firstOrFail();

            $activeYear = \App\Models\AcademicYear::where('status', 'ACTIVE')->first();
            $activeSemester = \App\Models\Semester::where('status', 'OPEN')->first();

            if (!$activeYear || !$activeSemester) {
                throw new \Exception("No active registration period is currently open.");
            }

            $registration = \App\Models\Registration::firstOrCreate(
                [
                    'student_id' => $student->student_id,
                    'academic_year_id' => $activeYear->academic_year_id,
                    'semester_id' => $activeSemester->semester_id,
                ],
                [
                    'registration_id' => 'reg_' . Str::random(12),
                    'total_credits' => 0,
                    'registration_status' => \App\Enums\RegistrationStatusEnum::DRAFT->value,
                    'verification_code' => 'RUSL-' . date('Y') . '-' . strtoupper(Str::random(6)),
                ]
            );

            $regCourse = \App\Models\RegistrationCourse::where('registration_id', $registration->registration_id)
                ->where('offering_id', $offering->offering_id)
                ->first();

            if ($regCourse) {
                $regCourse->update([
                    'course_status' => 'PENDING',
                    'dropped_at' => null,
                ]);
            } else {
                $regCourse = \App\Models\RegistrationCourse::create([
                    'registration_course_id' => 'rc_' . Str::random(12),
                    'registration_id' => $registration->registration_id,
                    'offering_id' => $offering->offering_id,
                    'registration_type' => 'NORMAL',
                    'course_status' => 'PENDING',
                    'added_at' => now(),
                ]);
            }

            $offering->increment('registration_count');
            $registration->recalculateCredits();

            $entry->update(['status' => 'CLAIMED']);

            return [
                'success' => true,
                'message' => 'Promoted seat successfully claimed and enrolled.',
                'course' => $offering->course->course_title ?? 'Course',
                'registration_id' => $registration->registration_id,
            ];
        });
    }

    /**
     * Expire promoted seats older than 24 hours and promote next in queue
     */
    public function expireStalePromotions(): int
    {
        $staleEntries = WaitingList::with('offering')
            ->where('status', 'PROMOTED')
            ->where('updated_at', '<', now()->subHours(24))
            ->get();

        $count = 0;
        foreach ($staleEntries as $entry) {
            DB::transaction(function () use ($entry, &$count) {
                $entry->update(['status' => 'EXPIRED']);
                $count++;

                if ($entry->offering) {
                    $this->processSeatVacated($entry->offering);
                }
            });
        }

        return $count;
    }
}
