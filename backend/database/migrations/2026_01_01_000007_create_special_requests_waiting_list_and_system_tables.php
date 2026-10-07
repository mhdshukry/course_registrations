<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Special Requests, Waiting Lists, Notifications, Audit Logs and Settings.
     */
    public function up(): void
    {
        Schema::create('special_requests', function (Blueprint $table) {
            $table->string('request_id', 36)->primary();
            $table->string('student_id', 36);
            $table->string('registration_id', 36)->nullable();
            $table->string('request_type', 30); // OVERLOAD, PREREQUISITE_WAIVER, LATE_REGISTRATION, TIMETABLE_CLASH, SUBSTITUTION
            $table->text('reason');
            $table->string('attachment_url', 255)->nullable();
            $table->string('request_status', 20)->default('PENDING'); // PENDING, APPROVED, REJECTED
            $table->timestamp('submitted_at')->useCurrent();
            $table->timestamps();

            $table->foreign('student_id')->references('student_id')->on('students')->cascadeOnDelete();
            $table->foreign('registration_id')->references('registration_id')->on('registrations')->nullOnDelete();
        });

        Schema::create('request_approvals', function (Blueprint $table) {
            $table->string('request_approval_id', 36)->primary();
            $table->string('request_id', 36);
            $table->string('reviewer_user_id', 36);
            $table->string('decision', 20); // APPROVED, REJECTED
            $table->text('comments')->nullable();
            $table->timestamp('reviewed_at')->useCurrent();
            $table->timestamps();

            $table->foreign('request_id')->references('special_requests')->on('special_requests')->cascadeOnDelete();
            $table->foreign('reviewer_user_id')->references('user_id')->on('users');
        });

        Schema::create('waiting_lists', function (Blueprint $table) {
            $table->string('waiting_list_id', 36)->primary();
            $table->string('offering_id', 36);
            $table->string('student_id', 36);
            $table->integer('position');
            $table->string('status', 20)->default('WAITING'); // WAITING, PROMOTED, EXPIRED, CANCELLED
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamps();

            $table->foreign('offering_id')->references('offering_id')->on('course_offerings')->cascadeOnDelete();
            $table->foreign('student_id')->references('student_id')->on('students')->cascadeOnDelete();
            $table->unique(['offering_id', 'student_id']);
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->string('notification_id', 36)->primary();
            $table->string('user_id', 36);
            $table->string('notification_type', 30); // STATUS_CHANGE, DEADLINE_ALERT, WAITING_LIST_SEAT, ADVISER_COMMENT
            $table->string('title', 150);
            $table->text('message');
            $table->boolean('is_read')->default(false);
            $table->timestamp('sent_at')->useCurrent();
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->cascadeOnDelete();
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->string('audit_log_id', 36)->primary();
            $table->string('user_id', 36)->nullable();
            $table->string('action', 50);
            $table->string('entity_type', 50);
            $table->string('entity_id', 36);
            $table->text('old_data')->nullable();
            $table->text('new_data')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('user_id')->references('user_id')->on('users')->nullOnDelete();
            $table->index('user_id');
        });

        Schema::create('system_settings', function (Blueprint $table) {
            $table->string('setting_id', 36)->primary();
            $table->string('setting_key', 100)->unique();
            $table->text('setting_value');
            $table->string('faculty_id', 36)->nullable();
            $table->string('programme_id', 36)->nullable();
            $table->timestamps();

            $table->foreign('faculty_id')->references('faculty_id')->on('faculties')->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('system_settings');
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('waiting_lists');
        Schema::dropIfExists('request_approvals');
        Schema::dropIfExists('special_requests');
    }
};
