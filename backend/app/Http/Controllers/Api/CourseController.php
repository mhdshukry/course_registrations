<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\CourseOffering;
use App\Models\TimetableSlot;
use App\Services\ValidationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    protected ValidationService $validationService;

    public function __construct(ValidationService $validationService)
    {
        $this->validationService = $validationService;
    }

    /**
     * Get list of course offerings for active semester
     */
    public function offerings(Request $request): JsonResponse
    {
        $query = CourseOffering::with([
            'course.department',
            'course.prerequisites',
            'lecturer.user',
            'groups.timetableSlots',
        ]);

        if ($request->has('semester_id')) {
            $query->where('semester_id', $request->query('semester_id'));
        }

        if ($request->has('department_id')) {
            $query->where('department_id', $request->query('department_id'));
        }

        $offerings = $query->get()->map(function ($offering) {
            return [
                'offering_id' => $offering->offering_id,
                'course_id' => $offering->course_id,
                'course_code' => $offering->course->course_code ?? '',
                'course_title' => $offering->course->course_title ?? '',
                'credit_value' => $offering->course->credit_value ?? 0,
                'course_level' => $offering->course->course_level ?? 1,
                'capacity' => $offering->capacity,
                'registration_count' => $offering->registration_count,
                'available_seats' => $offering->availableSeats(),
                'is_full' => $offering->isFull(),
                'lecturer' => $offering->lecturer?->user?->username ?? 'TBA',
                'delivery_mode' => $offering->delivery_mode,
                'groups' => $offering->groups->map(function ($group) {
                    return [
                        'group_id' => $group->group_id,
                        'group_name' => $group->group_name,
                        'group_type' => $group->group_type,
                        'slots' => $group->timetableSlots->map(fn($s) => [
                            'slot_id' => $s->timetable_slot_id,
                            'day' => $s->day_of_week,
                            'start' => $s->start_time,
                            'end' => $s->end_time,
                            'venue' => $s->venue,
                        ]),
                    ];
                }),
                'prerequisites' => $offering->course->prerequisites->map(fn($p) => [
                    'code' => $p->course_code,
                    'title' => $p->course_title,
                ]),
            ];
        });

        return response()->json([
            'success' => true,
            'count' => $offerings->count(),
            'data' => $offerings,
        ]);
    }

    /**
     * Check if chosen course offerings cause a timetable clash
     */
    public function checkClashes(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'group_ids' => 'required|array',
            'group_ids.*' => 'string',
        ]);

        $slots = TimetableSlot::whereIn('group_id', $validated['group_ids'])->get();
        $result = $this->validationService->checkTimetableClashes($slots);

        return response()->json([
            'success' => true,
            'has_clash' => !$result['valid'],
            'clashes' => $result['clashes'],
        ]);
    }

    /**
     * Check prerequisite satisfaction for selected courses
     */
    public function checkPrerequisites(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'course_ids' => 'required|array',
            'course_ids.*' => 'string',
        ]);

        $student = $request->user()->student;
        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Only student profiles can check prerequisite eligibility.',
            ], 403);
        }

        $result = $this->validationService->validatePrerequisites($student, $validated['course_ids']);

        return response()->json([
            'success' => true,
            'eligible' => $result['valid'],
            'missing' => $result['missingPrerequisites'],
        ]);
    }
}
