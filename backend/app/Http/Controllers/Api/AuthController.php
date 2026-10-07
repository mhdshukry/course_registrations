<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * User Login and Token Generation
     */
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $identifier = $credentials['username'];

        $user = User::with(['roles', 'student.programme', 'student.department', 'student.faculty', 'staff'])
            ->where('username', $identifier)
            ->orWhere('email', $identifier)
            ->orWhereHas('student', function ($query) use ($identifier) {
                $query->where('registration_number', $identifier);
            })
            ->orWhereHas('staff', function ($query) use ($identifier) {
                $query->where('employee_number', $identifier);
            })
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid username, registration number or password credentials.',
            ], 401);
        }

        // Validate password against hashed password in database
        if (!Hash::check($credentials['password'], $user->password_hash)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid username, registration number or password credentials.',
            ], 401);
        }

        if ($user->account_status !== 'ACTIVE') {
            return response()->json([
                'success' => false,
                'message' => 'Account is deactivated or suspended. Please contact the Faculty Administrator.',
            ], 403);
        }

        // Update last login
        $user->update(['last_login' => now()]);

        // Create Sanctum API token
        $token = $user->createToken('rusl-auth-token')->plainTextToken;

        // Audit log
        AuditLog::create([
            'audit_log_id' => 'aud_' . Str::random(12),
            'user_id' => $user->user_id,
            'action' => 'USER_LOGIN',
            'entity_type' => 'User',
            'entity_id' => $user->user_id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'created_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Authentication successful.',
            'data' => [
                'token' => $token,
                'user' => [
                    'user_id' => $user->user_id,
                    'username' => $user->username,
                    'full_name' => $user->full_name,
                    'email' => $user->email,
                    'roles' => $user->roles->pluck('role_name'),
                    'student' => $user->student,
                    'staff' => $user->staff,
                ],
            ],
        ]);
    }

    /**
     * Current authenticated user profile
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load([
            'roles',
            'student.faculty',
            'student.department',
            'student.programme',
            'student.curriculum',
            'staff.faculty',
            'staff.department',
        ]);

        return response()->json([
            'success' => true,
            'data' => $user,
        ]);
    }

    /**
     * Invalidate Token and Logout
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
        ]);
    }
}
