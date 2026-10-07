<?php

namespace Database\Seeders;

use App\Models\AcademicYear;
use App\Models\Programme;
use App\Models\Semester;
use Illuminate\Database\Seeder;

class ProgrammeAndCalendarSeeder extends Seeder
{
    public function run(): void
    {
        $programmes = [
            [
                'programme_id' => 'p_bict',
                'department_id' => 'd_ict',
                'programme_code' => 'BICT_HONS',
                'programme_name' => 'Bachelor of Information and Communication Technology Honours',
                'degree_type' => 'BSc Honours',
                'duration_years' => 4,
                'total_credits' => 120,
            ],
            [
                'programme_id' => 'p_bpt',
                'department_id' => 'd_bpt',
                'programme_code' => 'BBPT_HONS',
                'programme_name' => 'Bachelor of Bio-Process Technology Honours',
                'degree_type' => 'BSc Honours',
                'duration_years' => 4,
                'total_credits' => 120,
            ],
            [
                'programme_id' => 'p_cs',
                'department_id' => 'd_cs',
                'programme_code' => 'BSCCS_HONS',
                'programme_name' => 'Bachelor of Science Honours in Computer Science',
                'degree_type' => 'BSc Honours',
                'duration_years' => 4,
                'total_credits' => 120,
            ],
            [
                'programme_id' => 'p_bba',
                'department_id' => 'd_acc',
                'programme_code' => 'BBA_HONS',
                'programme_name' => 'Bachelor of Business Administration Honours',
                'degree_type' => 'BBA Honours',
                'duration_years' => 4,
                'total_credits' => 120,
            ],
        ];

        foreach ($programmes as $p) {
            Programme::updateOrCreate(['programme_id' => $p['programme_id']], $p);
        }

        $academicYear = AcademicYear::updateOrCreate(
            ['academic_year_id' => 'ay_2025'],
            [
                'year_name' => '2025/2026',
                'start_date' => '2025-09-01',
                'end_date' => '2026-08-31',
                'status' => 'ACTIVE',
            ]
        );

        Semester::updateOrCreate(
            ['semester_id' => 'sem_5'],
            [
                'academic_year_id' => $academicYear->academic_year_id,
                'semester_number' => 1,
                'semester_name' => 'Semester 5 (Level 3 Sem 1)',
                'start_date' => '2026-02-01',
                'end_date' => '2026-07-31',
                'status' => 'OPEN',
            ]
        );
    }
}
