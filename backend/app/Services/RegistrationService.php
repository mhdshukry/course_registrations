<?php

namespace App\Services;

use App\Enums\RegistrationStatusEnum;
use App\Models\AuditLog;
use App\Models\CourseOffering;
use App\Models\Notification;
use App\Models\Registration;
use App\Models\RegistrationCourse;
use App\Models\Student;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class RegistrationService
{
    protected ValidationService $validationService;
    protected WaitingListService $waitingListService;

    public function __construct(ValidationService $validationService, WaitingListService $waitingListService)
    {
        $this->validationService = $validationService;
        $this->waitingListService = $waitingListService;
    }

    /**
     * Get or create a draft registration for a student for the active academic year/semester
     */
    public function getOrCreateRegistration(Student $student, string $academicYearId, string $semesterId): Registration
    {
        return Registration::firstOrCreate(
            [
                'student_id' => $student->student_id,
                'academic_year_id' => $academicYearId,
                'semester_id' => $semesterId,
            ],
            [
                'registration_id' => 'reg_' . Str::random(12),
                'total_credits' => 0,
                'registration_status' => RegistrationStatusEnum::DRAFT->value,
                'verification_code' => 'RUSL-' . date('Y') . '-' . strtoupper(Str::random(6)),
            ]
        );
    }

    /**
     * Add course to registration
     */
    public function addCourse(Registration $registration, string $offeringId, ?string $groupId = null, string $type = 'NORMAL'): RegistrationCourse
    {
        return DB::transaction(function () use ($registration, $offeringId, $groupId, $type) {
            $offering = CourseOffering::where('offering_id', $offeringId)->lockForUpdate()->firstOrFail();

            // Check if offering is full
            if ($offering->isFull()) {
                throw new \Exception("Course offering is at full capacity. Please join the waiting list.");
            }

            // Check if already added
            $existing = RegistrationCourse::where('registration_id', $registration->registration_id)
                ->where('offering_id', $offeringId)
                ->first();

            if ($existing) {
                if ($existing->course_status === 'DROPPED') {
                    $existing->update([
                        'course_status' => 'PENDING',
                        'dropped_at' => null,
                        'group_id' => $groupId,
                        'registration_type' => $type,
                    ]);
                    $offering->increment('registration_count');
                    $registration->recalculateCredits();
                    return $existing;
                }
                return $existing;
            }

            $regCourse = RegistrationCourse::create([
                'registration_course_id' => 'rc_' . Str::random(12),
                'registration_id' => $registration->registration_id,
                'offering_id' => $offeringId,
                'group_id' => $groupId,
                'registration_type' => $type,
                'course_status' => 'PENDING',
                'added_at' => now(),
            ]);

            $offering->increment('registration_count');
            $registration->recalculateCredits();

            return $regCourse;
        });
    }

    /**
     * Drop course from registration
     */
    public function dropCourse(Registration $registration, string $offeringId): bool
    {
        return DB::transaction(function () use ($registration, $offeringId) {
            $regCourse = RegistrationCourse::where('registration_id', $registration->registration_id)
                ->where('offering_id', $offeringId)
                ->where('course_status', '!=', 'DROPPED')
                ->first();

            if (!$regCourse) {
                return false;
            }

            $regCourse->update([
                'course_status' => 'DROPPED',
                'dropped_at' => now(),
            ]);

            $offering = CourseOffering::where('offering_id', $offeringId)->lockForUpdate()->first();
            if ($offering && $offering->registration_count > 0) {
                $offering->decrement('registration_count');
                // Check if waiting list candidate can take the vacated seat
                $this->waitingListService->processSeatVacated($offering);
            }

            $registration->recalculateCredits();

            return true;
        });
    }

    /**
     * Submit registration for approval
     */
    public function submitRegistration(Registration $registration): array
    {
        $registration->load(['student', 'registrationCourses.offering.course']);
        $student = $registration->student;

        // Recalculate credits
        $registration->recalculateCredits();

        // Validate credit limits
        $creditValidation = $this->validationService->validateCreditLimits($student, $registration->total_credits);
        if (!$creditValidation['valid']) {
            return [
                'success' => false,
                'message' => $creditValidation['message'],
            ];
        }

        // Validate prerequisites
        $activeCourseIds = $registration->registrationCourses
            ->where('course_status', '!=', 'DROPPED')
            ->pluck('offering.course_id')
            ->filter()
            ->all();

        $prereqValidation = $this->validationService->validatePrerequisites($student, $activeCourseIds);
        if (!$prereqValidation['valid']) {
            $names = array_map(fn($item) => "{$item['course_code']} requires {$item['prerequisite_code']}", $prereqValidation['missingPrerequisites']);
            return [
                'success' => false,
                'message' => 'Prerequisite check failed: ' . implode(', ', $names),
            ];
        }

        // Validate timetable clashes
        $activeGroupIds = $registration->registrationCourses
            ->where('course_status', '!=', 'DROPPED')
            ->pluck('group_id')
            ->filter()
            ->all();

        if (!empty($activeGroupIds)) {
            $slots = \App\Models\TimetableSlot::whereIn('group_id', $activeGroupIds)->get();
            $clashValidation = $this->validationService->checkTimetableClashes($slots);
            if (!$clashValidation['valid']) {
                return [
                    'success' => false,
                    'message' => 'Registration contains timetable clashes. Please resolve timetable overlaps before submission.',
                    'clashes' => $clashValidation['clashes'],
                ];
            }
        }

        // Update status to SUBMITTED
        $registration->update([
            'registration_status' => RegistrationStatusEnum::SUBMITTED->value,
            'submitted_at' => now(),
        ]);

        // Audit Log
        AuditLog::create([
            'audit_log_id' => 'aud_' . Str::random(12),
            'user_id' => $student->user_id,
            'action' => 'REGISTRATION_SUBMITTED',
            'entity_type' => 'Registration',
            'entity_id' => $registration->registration_id,
            'old_data' => json_encode(['status' => 'DRAFT']),
            'new_data' => json_encode(['status' => 'SUBMITTED', 'credits' => $registration->total_credits]),
            'created_at' => now(),
        ]);

        // Create In-App Notification
        Notification::create([
            'notification_id' => 'notif_' . Str::random(12),
            'user_id' => $student->user_id,
            'notification_type' => 'STATUS_CHANGE',
            'title' => 'Registration Submitted',
            'message' => 'Your course registration slip has been forwarded to the Head of Department (HoD) for endorsement.',
            'is_read' => false,
            'sent_at' => now(),
        ]);

        return [
            'success' => true,
            'message' => 'Registration submitted successfully.',
            'registration' => $registration,
        ];
    }
}
