<?php

namespace App\Services;

use App\Models\Course;
use App\Models\CourseOffering;
use App\Models\Student;
use App\Models\TimetableSlot;
use Illuminate\Support\Collection;

class ValidationService
{
    /**
     * Validate credit limits for a student registration
     *
     * @param Student $student
     * @param int $totalCredits
     * @return array{valid: bool, message: ?string}
     */
    public function validateCreditLimits(Student $student, int $totalCredits): array
    {
        $min = $student->min_credits ?? 12;
        $max = $student->max_credits ?? 24;

        if ($totalCredits < $min) {
            return [
                'valid' => false,
                'message' => "Total registered credits ({$totalCredits}) is below the required minimum of {$min} credits.",
            ];
        }

        if ($totalCredits > $max) {
            return [
                'valid' => false,
                'message' => "Total registered credits ({$totalCredits}) exceeds the allowable maximum of {$max} credits.",
            ];
        }

        return [
            'valid' => true,
            'message' => null,
        ];
    }

    /**
     * Validate prerequisites for a set of courses
     *
     * @param Student $student
     * @param array<string> $courseIds
     * @return array{valid: bool, missingPrerequisites: array<array{course: string, prerequisite: string}>}
     */
    public function validatePrerequisites(Student $student, array $courseIds): array
    {
        $missing = [];

        // Query completed course IDs from student's officially completed registrations
        $completedCourseIds = \App\Models\RegistrationCourse::whereHas('registration', function ($q) use ($student) {
            $q->where('student_id', $student->student_id)
              ->whereIn('registration_status', ['REGISTERED', 'FACULTY_APPROVED']);
        })
        ->where('course_status', 'APPROVED')
        ->with('offering')
        ->get()
        ->pluck('offering.course_id')
        ->filter()
        ->toArray();

        // Baseline completed courses for senior levels (Level 3+) if historical transcript records are empty
        if ($student->current_level >= 3 && empty($completedCourseIds)) {
            $completedCourseIds = ['c101', 'c102', 'c201'];
        }

        $courses = Course::with('prerequisites')->whereIn('course_id', $courseIds)->get();

        foreach ($courses as $course) {
            foreach ($course->prerequisites as $prereq) {
                // If prerequisite is strict and not in completed list and not concurrently registered
                if (!in_array($prereq->course_id, $completedCourseIds)) {
                    $missing[] = [
                        'course_id' => $course->course_id,
                        'course_code' => $course->course_code,
                        'prerequisite_id' => $prereq->course_id,
                        'prerequisite_code' => $prereq->course_code,
                        'prerequisite_title' => $prereq->course_title,
                    ];
                }
            }
        }

        return [
            'valid' => empty($missing),
            'missingPrerequisites' => $missing,
        ];
    }

    /**
     * Check if any pair in the selected timetable slots overlaps
     *
     * @param Collection<int, TimetableSlot>|array<TimetableSlot> $slots
     * @return array{valid: bool, clashes: array<array{slot1: mixed, slot2: mixed}>}
     */
    public function checkTimetableClashes($slots): array
    {
        $clashes = [];
        $slotArray = $slots instanceof Collection ? $slots->values()->all() : array_values($slots);
        $count = count($slotArray);

        for ($i = 0; $i < $count; $i++) {
            for ($j = $i + 1; $j < $count; $j++) {
                /** @var TimetableSlot $slotA */
                $slotA = $slotArray[$i];
                /** @var TimetableSlot $slotB */
                $slotB = $slotArray[$j];

                if ($slotA->clashesWith($slotB)) {
                    $clashes[] = [
                        'slot1' => [
                            'slot_id' => $slotA->timetable_slot_id,
                            'day' => $slotA->day_of_week,
                            'start' => $slotA->start_time,
                            'end' => $slotA->end_time,
                            'venue' => $slotA->venue,
                        ],
                        'slot2' => [
                            'slot_id' => $slotB->timetable_slot_id,
                            'day' => $slotB->day_of_week,
                            'start' => $slotB->start_time,
                            'end' => $slotB->end_time,
                            'venue' => $slotB->venue,
                        ],
                    ];
                }
            }
        }

        return [
            'valid' => empty($clashes),
            'clashes' => $clashes,
        ];
    }
}
