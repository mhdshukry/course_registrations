<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Courses, Curriculum Courses, Prerequisites, Corequisites, and Equivalencies.
     */
    public function up(): void
    {
        Schema::create('courses', function (Blueprint $table) {
            $table->string('course_id', 36)->primary();
            $table->string('course_code', 20)->unique();
            $table->string('course_title', 200);
            $table->text('description')->nullable();
            $table->integer('credit_value');
            $table->integer('course_level');
            $table->string('owning_department_id', 36);
            $table->string('course_status', 20)->default('ACTIVE');
            $table->timestamps();

            $table->foreign('owning_department_id')->references('department_id')->on('departments');
            $table->index('course_code');
        });

        Schema::create('curriculum_courses', function (Blueprint $table) {
            $table->string('curriculum_course_id', 36)->primary();
            $table->string('curriculum_id', 36);
            $table->string('course_id', 36);
            $table->integer('semester_number');
            $table->string('course_type', 20); // COMPULSORY, ELECTIVE, OPTIONAL, REPEAT, NON_CREDIT, AUDIT
            $table->boolean('is_compulsory')->default(true);
            $table->string('elective_group_id', 36)->nullable();
            $table->timestamps();

            $table->foreign('curriculum_id')->references('curriculum_id')->on('curricula')->cascadeOnDelete();
            $table->foreign('course_id')->references('course_id')->on('courses')->cascadeOnDelete();
        });

        Schema::create('course_prerequisites', function (Blueprint $table) {
            $table->string('prerequisite_id', 36)->primary();
            $table->string('course_id', 36);
            $table->string('prerequisite_course_id', 36);
            $table->string('minimum_grade', 5)->default('C');
            $table->string('rule_type', 20)->default('STRICT'); // STRICT, WAIVABLE
            $table->timestamps();

            $table->foreign('course_id')->references('course_id')->on('courses')->cascadeOnDelete();
            $table->foreign('prerequisite_course_id')->references('course_id')->on('courses')->cascadeOnDelete();
            $table->unique(['course_id', 'prerequisite_course_id']);
        });

        Schema::create('course_corequisites', function (Blueprint $table) {
            $table->string('corequisite_id', 36)->primary();
            $table->string('course_id', 36);
            $table->string('corequisite_course_id', 36);
            $table->timestamps();

            $table->foreign('course_id')->references('course_id')->on('courses')->cascadeOnDelete();
            $table->foreign('corequisite_course_id')->references('course_id')->on('courses')->cascadeOnDelete();
        });

        Schema::create('course_equivalencies', function (Blueprint $table) {
            $table->string('equivalency_id', 36)->primary();
            $table->string('old_course_id', 36);
            $table->string('new_course_id', 36);
            $table->string('equivalency_type', 30)->default('DIRECT_REPLACEMENT');
            $table->date('effective_date');
            $table->timestamps();

            $table->foreign('old_course_id')->references('course_id')->on('courses');
            $table->foreign('new_course_id')->references('course_id')->on('courses');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('course_equivalencies');
        Schema::dropIfExists('course_corequisites');
        Schema::dropIfExists('course_prerequisites');
        Schema::dropIfExists('curriculum_courses');
        Schema::dropIfExists('courses');
    }
};
