<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database in dependency order.
     */
    public function run(): void
    {
        $this->call([
            FacultyDepartmentSeeder::class,
            ProgrammeAndCalendarSeeder::class,
            UserAndRoleSeeder::class,
            CourseAndCurriculumSeeder::class,
            CourseOfferingAndTimetableSeeder::class,
        ]);
    }
}
