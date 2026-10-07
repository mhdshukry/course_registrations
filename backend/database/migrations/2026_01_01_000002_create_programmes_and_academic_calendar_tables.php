<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Programmes, Academic Years and Semesters.
     */
    public function up(): void
    {
        Schema::create('programmes', function (Blueprint $table) {
            $table->string('programme_id', 36)->primary();
            $table->string('department_id', 36);
            $table->string('programme_code', 15)->unique();
            $table->string('programme_name', 200);
            $table->string('degree_type', 50);
            $table->integer('duration_years')->default(4);
            $table->integer('total_credits')->default(120);
            $table->string('status', 20)->default('ACTIVE');
            $table->timestamps();

            $table->foreign('department_id')->references('department_id')->on('departments')->cascadeOnDelete();
        });

        Schema::create('academic_years', function (Blueprint $table) {
            $table->string('academic_year_id', 36)->primary();
            $table->string('year_name', 20)->unique();
            $table->date('start_date');
            $table->date('end_date');
            $table->string('status', 20)->default('UPCOMING');
            $table->timestamps();
        });

        Schema::create('semesters', function (Blueprint $table) {
            $table->string('semester_id', 36)->primary();
            $table->string('academic_year_id', 36);
            $table->integer('semester_number');
            $table->string('semester_name', 50);
            $table->date('start_date');
            $table->date('end_date');
            $table->string('status', 20)->default('PLANNED');
            $table->timestamps();

            $table->foreign('academic_year_id')->references('academic_year_id')->on('academic_years')->cascadeOnDelete();
            $table->unique(['academic_year_id', 'semester_number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('semesters');
        Schema::dropIfExists('academic_years');
        Schema::dropIfExists('programmes');
    }
};
