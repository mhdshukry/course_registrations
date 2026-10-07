<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AcademicYear;
use App\Models\Registration;
use App\Models\Semester;
use App\Services\RegistrationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegistrationController extends Controller
{
    protected RegistrationService $registrationService;

    public function __construct(RegistrationService $registrationService)
    {
        $this->registrationService = $registrationService;
    }

    /**
     * Get or initialize active student registration
     */
    public function current(Request $request): JsonResponse
    {
        $user = $request->user();
        $student = $user->student;

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'No student profile associated with this account.',
            ], 404);
        }

        // Active Academic Year & Semester
        $activeYear = AcademicYear::where('status', 'ACTIVE')->first();
        $activeSemester = Semester::where('status', 'OPEN')->first();

        if (!$activeYear || !$activeSemester) {
            return response()->json([
                'success' => false,
                'message' => 'No registration period is currently open.',
            ], 400);
        }

        $registration = $this->registrationService->getOrCreateRegistration(
            $student,
            $activeYear->academic_year_id,
            $activeSemester->semester_id
        );

        $registration->load([
            'academicYear',
            'semester',
            'registrationCourses.offering.course',
            'registrationCourses.group.timetableSlots',
            'approvals.approver',
        ]);

        return response()->json([
            'success' => true,
            'data' => $registration,
        ]);
    }

    /**
     * Add course offering to active registration
     */
    public function addCourse(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'registration_id' => 'required|string',
            'offering_id' => 'required|string',
            'group_id' => 'nullable|string',
            'registration_type' => 'nullable|string|in:NORMAL,REPEAT,AUDIT,SPECIAL',
        ]);

        $registration = Registration::findOrFail($validated['registration_id']);

        // Check if student owns registration
        if ($registration->student->user_id !== $request->user()->user_id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        // Must be in draft or changes requested
        if (!in_array($registration->registration_status, ['DRAFT', 'CHANGES_REQUESTED'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot modify a registration that has already been submitted or locked.',
            ], 422);
        }

        try {
            $regCourse = $this->registrationService->addCourse(
                $registration,
                $validated['offering_id'],
                $validated['group_id'] ?? null,
                $validated['registration_type'] ?? 'NORMAL'
            );

            return response()->json([
                'success' => true,
                'message' => 'Course enrolled successfully.',
                'data' => $regCourse,
                'total_credits' => $registration->total_credits,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Drop a course from registration
     */
    public function dropCourse(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'registration_id' => 'required|string',
            'offering_id' => 'required|string',
        ]);

        $registration = Registration::findOrFail($validated['registration_id']);

        if ($registration->student->user_id !== $request->user()->user_id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        if (!in_array($registration->registration_status, ['DRAFT', 'CHANGES_REQUESTED'])) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot drop courses after submission.',
            ], 422);
        }

        $dropped = $this->registrationService->dropCourse($registration, $validated['offering_id']);

        return response()->json([
            'success' => $dropped,
            'message' => $dropped ? 'Course removed.' : 'Course was not found in registration.',
            'total_credits' => $registration->total_credits,
        ]);
    }

    /**
     * Submit draft registration for academic review
     */
    public function submit(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'registration_id' => 'required|string',
        ]);

        $registration = Registration::findOrFail($validated['registration_id']);

        if ($registration->student->user_id !== $request->user()->user_id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $result = $this->registrationService->submitRegistration($registration);

        return response()->json($result, $result['success'] ? 200 : 422);
    }

    /**
     * Official registration verification slip data
     */
    public function slip(string $id): JsonResponse
    {
        $registration = Registration::with([
            'student.user',
            'student.programme',
            'student.department',
            'student.faculty',
            'academicYear',
            'semester',
            'registrationCourses' => fn($q) => $q->where('course_status', '!=', 'DROPPED'),
            'registrationCourses.offering.course',
            'approvals.approver',
        ])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => [
                'verification_code' => $registration->verification_code,
                'status' => $registration->registration_status,
                'student_name' => $registration->student->user->full_name ?? $registration->student->user->username,
                'reg_number' => $registration->student->registration_number,
                'faculty' => $registration->student->faculty->faculty_name,
                'degree' => $registration->student->programme->programme_name,
                'level' => $registration->student->current_level,
                'academic_year' => $registration->academicYear->year_name,
                'semester' => $registration->semester->semester_name,
                'total_credits' => $registration->total_credits,
                'submitted_at' => $registration->submitted_at,
                'approved_at' => $registration->approved_at,
                'courses' => $registration->registrationCourses->map(function ($rc) {
                    return [
                        'code' => $rc->offering->course->course_code ?? '',
                        'title' => $rc->offering->course->course_title ?? '',
                        'credits' => $rc->offering->course->credit_value ?? 0,
                        'type' => $rc->registration_type,
                    ];
                }),
                'qr_payload' => json_encode([
                    'code' => $registration->verification_code,
                    'reg_num' => $registration->student->registration_number,
                    'status' => $registration->registration_status,
                    'hash' => hash('sha256', $registration->verification_code . $registration->student_id),
                ]),
            ],
        ]);
    }

    /**
     * Bulk CSV export of registrations for Assistant Registrar & Exam Compliance
     */
    public function export(Request $request)
    {
        $user = $request->user();
        $roles = $user->roles->pluck('role_name')->toArray();
        $allowed = ['ASSISTANT_REGISTRAR', 'CENTRAL_ADMIN', 'FACULTY_COORDINATOR', 'HEAD_OF_DEPARTMENT'];

        if (!array_intersect($roles, $allowed)) {
            return response()->json(['success' => false, 'message' => 'Unauthorized for export.'], 403);
        }

        $query = Registration::with([
            'student.user',
            'student.programme',
            'student.faculty',
            'academicYear',
            'semester',
        ]);

        if ($request->has('status')) {
            $query->where('registration_status', $request->query('status'));
        }

        $registrations = $query->get();

        $csvHeader = "Registration ID,Registration No,Student Name,Degree Programme,Academic Year,Semester,Credits,Status,Submitted At,Approved At\n";
        $csvRows = [];

        foreach ($registrations as $r) {
            $csvRows[] = sprintf(
                '"%s","%s","%s","%s","%s","%s",%d,"%s","%s","%s"',
                $r->registration_id,
                $r->student->registration_number ?? '',
                $r->student->user->full_name ?? $r->student->user->username ?? '',
                $r->student->programme->programme_name ?? '',
                $r->academicYear->year_name ?? '',
                $r->semester->semester_name ?? '',
                $r->total_credits,
                $r->registration_status,
                $r->submitted_at ?? '',
                $r->approved_at ?? ''
            );
        }

        $csvData = $csvHeader . implode("\n", $csvRows);

        return response($csvData, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="rusl_registrations_export_' . date('Ymd_His') . '.csv"',
        ]);
    }
}
