<?php

namespace App\Http\Controllers\Api;

use App\Enums\RegistrationStatusEnum;
use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Notification;
use App\Models\Registration;
use App\Models\RegistrationApproval;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ApprovalController extends Controller
{
    /**
     * List registrations pending review for the logged-in staff member
     */
    public function pending(Request $request): JsonResponse
    {
        $user = $request->user()->load('staff');
        $roles = $user->roles->pluck('role_name')->toArray();

        $applicableStatuses = [];
        if (in_array('SYSTEM_ADMIN', $roles)) {
            $applicableStatuses = [
                RegistrationStatusEnum::SUBMITTED->value,
                RegistrationStatusEnum::HOD_APPROVED->value,
            ];
        } else {
            if (in_array('HEAD_OF_DEPARTMENT', $roles)) {
                $applicableStatuses[] = RegistrationStatusEnum::SUBMITTED->value;
            }
            if (in_array('ASSISTANT_REGISTRAR', $roles)) {
                $applicableStatuses[] = RegistrationStatusEnum::HOD_APPROVED->value;
            }
        }

        if (empty($applicableStatuses)) {
            return response()->json(['success' => false, 'message' => 'Unauthorized for registration approvals.'], 403);
        }

        $query = Registration::with([
            'student.user',
            'student.programme',
            'academicYear',
            'semester',
            'registrationCourses.offering.course',
        ])->whereIn('registration_status', $applicableStatuses);

        // Tenant Scoping: Department scope for HoDs (SYSTEM_ADMIN has global scope)
        if (!in_array('SYSTEM_ADMIN', $roles)) {
            if ($user->staff && $user->staff->department_id && !in_array('ASSISTANT_REGISTRAR', $roles)) {
                $query->whereHas('student', function ($q) use ($user) {
                    $q->where('department_id', $user->staff->department_id);
                });
            } elseif ($user->staff && $user->staff->faculty_id) {
                // Faculty scope for Assistant Registrars
                $query->whereHas('student', function ($q) use ($user) {
                    $q->where('faculty_id', $user->staff->faculty_id);
                });
            }
        }

        $registrations = $query->latest('submitted_at')->get();

        return response()->json([
            'success' => true,
            'count' => $registrations->count(),
            'data' => $registrations,
        ]);
    }

    /**
     * Approve registration at the user's role level
     */
    public function approve(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'comments' => 'nullable|string|max:500',
        ]);

        $registration = Registration::with(['student.user', 'student.department', 'student.faculty'])->findOrFail($id);
        $user = $request->user()->load('staff');
        $roles = $user->roles->pluck('role_name')->toArray();

        $currentStatus = $registration->registration_status;
        $nextStatus = null;
        $level = null;

        // Dynamic State Machine: Evaluate transition based on registration's current status and user's role capabilities
        if (in_array('SYSTEM_ADMIN', $roles)) {
            // System Admin has full override control over any step
            $level = 'SYSTEM_ADMIN';
            if ($currentStatus === RegistrationStatusEnum::SUBMITTED->value) {
                $nextStatus = RegistrationStatusEnum::HOD_APPROVED->value;
            } else {
                $nextStatus = RegistrationStatusEnum::REGISTERED->value;
                $registration->approved_at = now();
            }
        } elseif ($currentStatus === RegistrationStatusEnum::SUBMITTED->value && in_array('HEAD_OF_DEPARTMENT', $roles)) {
            $level = 'HOD';
            $nextStatus = RegistrationStatusEnum::HOD_APPROVED->value;
        } elseif (($currentStatus === RegistrationStatusEnum::HOD_APPROVED->value || $currentStatus === RegistrationStatusEnum::FACULTY_APPROVED->value) && in_array('ASSISTANT_REGISTRAR', $roles)) {
            $level = 'FACULTY_AR';
            $nextStatus = RegistrationStatusEnum::REGISTERED->value;
            $registration->approved_at = now();
        } else {
            return response()->json([
                'success' => false,
                'message' => "Invalid workflow state: Cannot transition registration from '{$currentStatus}' with your assigned role(s).",
            ], 422);
        }

        // Scope verification: Confirm student belongs to reviewer's department / faculty (System Admin bypasses)
        if (!in_array('SYSTEM_ADMIN', $roles)) {
            if ($user->staff && $user->staff->department_id && $level === 'HOD') {
                if ($registration->student->department_id !== $user->staff->department_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized: Student belongs to another department.',
                    ], 403);
                }
            } elseif ($user->staff && $user->staff->faculty_id) {
                if ($registration->student->faculty_id !== $user->staff->faculty_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Unauthorized: Student belongs to another faculty.',
                    ], 403);
                }
            }
        }

        $oldStatus = $registration->registration_status;
        $registration->registration_status = $nextStatus;
        $registration->save();

        // Record Approval History
        RegistrationApproval::create([
            'approval_id' => 'app_' . Str::random(12),
            'registration_id' => $registration->registration_id,
            'approver_user_id' => $user->user_id,
            'approval_level' => $level,
            'decision' => 'APPROVED',
            'comments' => $validated['comments'] ?? null,
            'decided_at' => now(),
        ]);

        // Audit Log
        AuditLog::create([
            'audit_log_id' => 'aud_' . Str::random(12),
            'user_id' => $user->user_id,
            'action' => 'REGISTRATION_APPROVED_' . $level,
            'entity_type' => 'Registration',
            'entity_id' => $registration->registration_id,
            'old_data' => json_encode(['status' => $oldStatus]),
            'new_data' => json_encode(['status' => $nextStatus]),
            'created_at' => now(),
        ]);

        // Send Notification to student
        Notification::create([
            'notification_id' => 'notif_' . Str::random(12),
            'user_id' => $registration->student->user_id,
            'notification_type' => 'STATUS_CHANGE',
            'title' => 'Registration Endorsed by ' . $level,
            'message' => "Your course registration has been approved by your {$level}.",
            'is_read' => false,
            'sent_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => "Registration successfully approved at {$level} tier.",
            'new_status' => $nextStatus,
        ]);
    }

    /**
     * Request changes on registration (returns to student with comments)
     */
    public function requestChanges(Request $request, string $id): JsonResponse
    {
        $validated = $request->validate([
            'comments' => 'required|string|max:1000',
        ]);

        $registration = Registration::with('student.user')->findOrFail($id);
        $user = $request->user();

        $oldStatus = $registration->registration_status;
        $registration->registration_status = RegistrationStatusEnum::CHANGES_REQUESTED->value;
        $registration->save();

        // Record Decision
        RegistrationApproval::create([
            'approval_id' => 'app_' . Str::random(12),
            'registration_id' => $registration->registration_id,
            'approver_user_id' => $user->user_id,
            'approval_level' => 'STAFF_REVIEW',
            'decision' => 'CHANGES_REQUESTED',
            'comments' => $validated['comments'],
            'decided_at' => now(),
        ]);

        // Notification to student
        Notification::create([
            'notification_id' => 'notif_' . Str::random(12),
            'user_id' => $registration->student->user_id,
            'notification_type' => 'ADVISER_COMMENT',
            'title' => 'Changes Requested on Registration',
            'message' => "Feedback from reviewer: " . $validated['comments'],
            'is_read' => false,
            'sent_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registration returned to student for requested changes.',
        ]);
    }
}
