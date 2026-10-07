<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations for Faculties and Departments.
     */
    public function up(): void
    {
        Schema::create('faculties', function (Blueprint $table) {
            $table->string('faculty_id', 36)->primary();
            $table->string('faculty_code', 10)->unique();
            $table->string('faculty_name', 150);
            $table->string('status', 20)->default('ACTIVE');
            $table->timestamps();
        });

        Schema::create('departments', function (Blueprint $table) {
            $table->string('department_id', 36)->primary();
            $table->string('faculty_id', 36);
            $table->string('department_code', 10);
            $table->string('department_name', 150);
            $table->string('status', 20)->default('ACTIVE');
            $table->timestamps();

            $table->foreign('faculty_id')->references('faculty_id')->on('faculties')->cascadeOnDelete();
            $table->unique(['faculty_id', 'department_code']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('departments');
        Schema::dropIfExists('faculties');
    }
};
