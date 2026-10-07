<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Users, Roles, User Roles, Students, and Staff.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->string('user_id', 36)->primary();
            $table->string('username', 50)->unique();
            $table->string('email', 100)->unique();
            $table->string('full_name', 150)->nullable();
            $table->string('first_name', 100)->nullable();
            $table->string('last_name', 100)->nullable();
            $table->string('phone_number', 25)->nullable();
            $table->string('password_hash', 255);
            $table->string('account_status', 20)->default('ACTIVE');
            $table->timestamp('last_login')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('roles', function (Blueprint $table) {
            $table->string('role_id', 36)->primary();
            $table->string('role_name', 50)->unique();
        });

        Schema::create('user_roles', function (Blueprint $table) {
            $table->string('user_role_id', 36)->primary();
            $table->string('user_id', 36);
            $table->string('role_id', 36);
            $table->string('faculty_id', 36)->nullable();
            $table->string('department_id', 36)->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->foreign('role_id')->references('role_id')->on('roles')->cascadeOnDelete();
            $table->foreign('faculty_id')->references('faculty_id')->on('faculties')->nullOnDelete();
            $table->foreign('department_id')->references('department_id')->on('departments')->nullOnDelete();
        });

        Schema::create('curricula', function (Blueprint $table) {
            $table->string('curriculum_id', 36)->primary();
            $table->string('programme_id', 36);
            $table->string('curriculum_name', 150);
            $table->string('version', 20);
            $table->integer('effective_year');
            $table->integer('total_credits');
            $table->string('status', 20)->default('ACTIVE');
            $table->timestamps();

            $table->foreign('programme_id')->references('programme_id')->on('programmes')->cascadeOnDelete();
        });

        Schema::create('students', function (Blueprint $table) {
            $table->string('student_id', 36)->primary();
            $table->string('user_id', 36)->unique();
            $table->string('registration_number', 30)->unique();
            $table->string('faculty_id', 36);
            $table->string('department_id', 36);
            $table->string('programme_id', 36);
            $table->string('curriculum_id', 36);
            $table->integer('intake_year');
            $table->integer('current_level')->default(1);
            $table->string('academic_status', 30)->default('GOOD_STANDING');
            $table->boolean('registration_eligibility')->default(true);
            $table->integer('min_credits')->default(12);
            $table->integer('max_credits')->default(24);
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->foreign('faculty_id')->references('faculty_id')->on('faculties');
            $table->foreign('department_id')->references('department_id')->on('departments');
            $table->foreign('programme_id')->references('programme_id')->on('programmes');
            $table->foreign('curriculum_id')->references('curriculum_id')->on('curricula');

            $table->index('faculty_id');
            $table->index('programme_id');
        });

        Schema::create('staff', function (Blueprint $table) {
            $table->string('staff_id', 36)->primary();
            $table->string('user_id', 36)->unique();
            $table->string('employee_number', 30)->unique();
            $table->string('faculty_id', 36);
            $table->string('department_id', 36);
            $table->string('designation', 100);
            $table->timestamps();

            $table->foreign('user_id')->references('user_id')->on('users')->cascadeOnDelete();
            $table->foreign('faculty_id')->references('faculty_id')->on('faculties');
            $table->foreign('department_id')->references('department_id')->on('departments');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('staff');
        Schema::dropIfExists('students');
        Schema::dropIfExists('curricula');
        Schema::dropIfExists('user_roles');
        Schema::dropIfExists('roles');
        Schema::dropIfExists('users');
    }
};
