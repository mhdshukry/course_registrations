<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Notification;
use App\Models\RequestApproval;
use App\Models\SpecialRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SpecialRequestController extends Controller
{
    /**
     * Submit a special academic request (Credit overload, prerequisite waiver, clash exemption)
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'request_type' => 'required|string|in:OVERLOAD,PREREQUISITE_WAIVER,LATE_REGISTRATION,TIMETABLE_CLASH,SUBSTITUTION',
            'reason' => 'required|string|min:10',
            'registration_id' => 'nullable|string',
            'attachment_url' => 'nullable|string',
        ]);

        $student = $request->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $specialRequest = SpecialRequest::create([
            'request_id' => 'sr_' . Str::random(12),
            'student_id' => $student->student_id,
            'registration_id' => $validated['registration_id'] ?? null,
            'request_type' => $validated['request_type'],
            'reason' => $validated['reason'],
            'attachment_url' => $validated['attachment_url'] ?? null,
            'request_status' => 'PENDING',
            'submitted_at' => now(),
        ]);

        AuditLog::create([
            'audit_log_id' => 'aud_' . Str::random(12),
            'user_id' => $request->user()->user_id,
            'action' => 'SPECIAL_REQUEST_SUBMITTED',
            'entity_type' => 'SpecialRequest',
            'entity_id' => $specialRequest->request_id,
            'created_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Special request submitted for faculty consideration.',
            'data' => $specialRequest,
        ]);
    }

    /**
     * List all special requests for the student
     */
    public function index(Request $request): JsonResponse
    {
        $student = $request->user()->student;
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $requests = SpecialRequest::with('approvals.reviewer')
            ->where('student_id', $student->student_id)
            ->latest('submitted_at')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $requests,
        ]);
    }

    /**
     * Review special request (Adviser or HoD)
     */
    public function review(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'decision' => 'required|string|in:APPROVED,REJECTED',
            'comments' => 'nullable|string',
        ]);

        $user = $request->user();
        $roles = $user->roles->pluck('role_name')->toArray();
        $allowedRoles = ['HEAD_OF_DEPARTMENT', 'ACADEMIC_ADVISER', 'FACULTY_COORDINATOR', 'CENTRAL_ADMIN'];

        if (!array_intersect($roles, $allowedRoles)) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Only Academic Advisers, Heads of Department, and Faculty Coordinators can review petitions.',
            ], 403);
        }

        $specialRequest = SpecialRequest::with('student.user')->findOrFail($id);

        $specialRequest->update([
            'request_status' => $validated['decision'],
        ]);

        // If Credit Overload is approved, raise student max_credits boundary
        if ($validated['decision'] === 'APPROVED' && $specialRequest->request_type === 'OVERLOAD') {
            $student = $specialRequest->student;
            if ($student) {
                $student->max_credits = max($student->max_credits + 3, 27);
                $student->save();
            }
        }

        RequestApproval::create([
            'request_approval_id' => 'ra_' . Str::random(12),
            'request_id' => $specialRequest->request_id,
            'reviewer_user_id' => $user->user_id,
            'decision' => $validated['decision'],
            'comments' => $validated['comments'] ?? null,
            'reviewed_at' => now(),
        ]);

        // Notification to student
        Notification::create([
            'notification_id' => 'notif_' . Str::random(12),
            'user_id' => $specialRequest->student->user_id,
            'notification_type' => 'STATUS_CHANGE',
            'title' => "Special Request {$validated['decision']}",
            'message' => "Your petition for {$specialRequest->request_type} has been {$validated['decision']}.",
            'is_read' => false,
            'sent_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => "Request has been {$validated['decision']}.",
        ]);
    }
}
