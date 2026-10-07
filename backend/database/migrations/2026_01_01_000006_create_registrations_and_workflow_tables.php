<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Registrations and Approval Workflow tables.
     */
    public function up(): void
    {
        Schema::create('registrations', function (Blueprint $table) {
            $table->string('registration_id', 36)->primary();
            $table->string('student_id', 36);
            $table->string('academic_year_id', 36);
            $table->string('semester_id', 36);
            $table->integer('total_credits')->default(0);
            $table->string('registration_status', 30)->default('DRAFT'); // DRAFT, SUBMITTED, CHANGES_REQUESTED, ADVISER_APPROVED, HOD_APPROVED, FACULTY_APPROVED, REGISTERED, LOCKED
            $table->timestamp('submitted_at')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('locked_at')->nullable();
            $table->string('verification_code', 100)->unique();
            $table->timestamps();

            $table->foreign('student_id')->references('student_id')->on('students')->cascadeOnDelete();
            $table->foreign('academic_year_id')->references('academic_year_id')->on('academic_years');
            $table->foreign('semester_id')->references('semester_id')->on('semesters');
            $table->unique(['student_id', 'academic_year_id', 'semester_id']);

            $table->index('student_id');
            $table->index('registration_status');
        });

        Schema::create('registration_courses', function (Blueprint $table) {
            $table->string('registration_course_id', 36)->primary();
            $table->string('registration_id', 36);
            $table->string('offering_id', 36);
            $table->string('group_id', 36)->nullable();
            $table->string('registration_type', 20)->default('NORMAL'); // NORMAL, REPEAT, AUDIT, SUBSTITUTE, SPECIAL
            $table->string('course_status', 20)->default('PENDING'); // PENDING, APPROVED, DROPPED
            $table->timestamp('added_at')->useCurrent();
            $table->timestamp('dropped_at')->nullable();
            $table->timestamps();

            $table->foreign('registration_id')->references('registration_id')->on('registrations')->cascadeOnDelete();
            $table->foreign('offering_id')->references('offering_id')->on('course_offerings')->cascadeOnDelete();
            $table->foreign('group_id')->references('group_id')->on('course_groups')->nullOnDelete();
            $table->unique(['registration_id', 'offering_id']);
        });

        Schema::create('registration_approvals', function (Blueprint $table) {
            $table->string('approval_id', 36)->primary();
            $table->string('registration_id', 36);
            $table->string('approver_user_id', 36);
            $table->string('approval_level', 30); // ADVISER, HOD, DEAN, FACULTY_AR
            $table->string('decision', 20); // APPROVED, REJECTED, CHANGES_REQUESTED
            $table->text('comments')->nullable();
            $table->timestamp('decided_at')->useCurrent();
            $table->timestamps();

            $table->foreign('registration_id')->references('registration_id')->on('registrations')->cascadeOnDelete();
            $table->foreign('approver_user_id')->references('user_id')->on('users');
        });

        Schema::create('registration_changes', function (Blueprint $table) {
            $table->string('change_id', 36)->primary();
            $table->string('registration_id', 36);
            $table->string('changed_by_user_id', 36);
            $table->text('previous_value');
            $table->text('new_value');
            $table->text('reason');
            $table->timestamp('changed_at')->useCurrent();
            $table->timestamps();

            $table->foreign('registration_id')->references('registration_id')->on('registrations')->cascadeOnDelete();
            $table->foreign('changed_by_user_id')->references('user_id')->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('registration_changes');
        Schema::dropIfExists('registration_approvals');
        Schema::dropIfExists('registration_courses');
        Schema::dropIfExists('registrations');
    }
};
