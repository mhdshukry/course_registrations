<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Course Offerings, Groups, and Timetable Slots.
     */
    public function up(): void
    {
        Schema::create('course_offerings', function (Blueprint $table) {
            $table->string('offering_id', 36)->primary();
            $table->string('course_id', 36);
            $table->string('academic_year_id', 36);
            $table->string('semester_id', 36);
            $table->string('department_id', 36);
            $table->string('lecturer_id', 36)->nullable();
            $table->integer('capacity')->default(60);
            $table->integer('registration_count')->default(0);
            $table->string('delivery_mode', 20)->default('PHYSICAL'); // PHYSICAL, ONLINE, HYBRID
            $table->string('offering_status', 20)->default('OPEN'); // OPEN, CLOSED, CANCELLED
            $table->timestamps();

            $table->foreign('course_id')->references('course_id')->on('courses')->cascadeOnDelete();
            $table->foreign('academic_year_id')->references('academic_year_id')->on('academic_years');
            $table->foreign('semester_id')->references('semester_id')->on('semesters');
            $table->foreign('lecturer_id')->references('staff_id')->on('staff')->nullOnDelete();

            $table->index('course_id');
        });

        Schema::create('course_groups', function (Blueprint $table) {
            $table->string('group_id', 36)->primary();
            $table->string('offering_id', 36);
            $table->string('group_name', 50); // e.g. "Lecture Group A", "Lab Group 1"
            $table->string('group_type', 20); // LECTURE, PRACTICAL, TUTORIAL, LAB
            $table->integer('maximum_capacity');
            $table->timestamps();

            $table->foreign('offering_id')->references('offering_id')->on('course_offerings')->cascadeOnDelete();
        });

        Schema::create('timetable_slots', function (Blueprint $table) {
            $table->string('timetable_slot_id', 36)->primary();
            $table->string('group_id', 36);
            $table->string('day_of_week', 15); // Monday, Tuesday, Wednesday, Thursday, Friday
            $table->time('start_time');
            $table->time('end_time');
            $table->string('venue', 100);
            $table->timestamps();

            $table->foreign('group_id')->references('group_id')->on('course_groups')->cascadeOnDelete();
            $table->index('group_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('timetable_slots');
        Schema::dropIfExists('course_groups');
        Schema::dropIfExists('course_offerings');
    }
};
