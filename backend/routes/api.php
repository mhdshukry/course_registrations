<?php

use App\Http\Controllers\Api\ApprovalController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CourseController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\RegistrationController;
use App\Http\Controllers\Api\SpecialRequestController;
use App\Http\Controllers\Api\WaitingListController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| RUSL Smart Course Registration API Routes
|--------------------------------------------------------------------------
|
| Base URL: /api/v1
|
*/

Route::prefix('v1')->group(function () {

    // -------------------------------------------------------------------------
    // Public Endpoints
    // -------------------------------------------------------------------------
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:5,1');
    Route::get('/courses/offerings', [CourseController::class, 'offerings']);
    Route::get('/registrations/{id}/slip', [RegistrationController::class, 'slip']);

    // -------------------------------------------------------------------------
    // Protected Endpoints (Requires Sanctum Bearer Token)
    // -------------------------------------------------------------------------
    Route::middleware('auth:sanctum')->group(function () {

        // Session & Identity
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        // Course Validation Checks
        Route::post('/courses/check-clashes', [CourseController::class, 'checkClashes']);
        Route::post('/courses/check-prerequisites', [CourseController::class, 'checkPrerequisites']);

        // Student Course Registration Flow
        Route::prefix('registrations')->group(function () {
            Route::get('/current', [RegistrationController::class, 'current']);
            Route::get('/export', [RegistrationController::class, 'export']);
            Route::post('/add-course', [RegistrationController::class, 'addCourse']);
            Route::post('/drop-course', [RegistrationController::class, 'dropCourse']);
            Route::post('/submit', [RegistrationController::class, 'submit']);
        });

        // Multi-Tier Staff Approvals Workflow
        Route::prefix('approvals')->group(function () {
            Route::get('/pending', [ApprovalController::class, 'pending']);
            Route::post('/{id}/approve', [ApprovalController::class, 'approve']);
            Route::post('/{id}/request-changes', [ApprovalController::class, 'requestChanges']);
        });

        // Waiting Lists
        Route::prefix('waiting-list')->group(function () {
            Route::get('/my-queues', [WaitingListController::class, 'myWaitingLists']);
            Route::post('/join', [WaitingListController::class, 'join']);
            Route::post('/leave', [WaitingListController::class, 'leave']);
            Route::post('/{id}/claim', [WaitingListController::class, 'claim']);
        });

        // Special Petitions & Requests
        Route::prefix('special-requests')->group(function () {
            Route::get('/', [SpecialRequestController::class, 'index']);
            Route::post('/', [SpecialRequestController::class, 'store']);
            Route::post('/{id}/review', [SpecialRequestController::class, 'review']);
        });

        // Notifications
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::patch('/{id}/read', [NotificationController::class, 'markAsRead']);
            Route::patch('/read-all', [NotificationController::class, 'markAllAsRead']);
        });
    });
});
