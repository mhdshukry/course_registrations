<?php

namespace Database\Seeders;

use App\Models\Department;
use App\Models\Faculty;
use Illuminate\Database\Seeder;

class FacultyDepartmentSeeder extends Seeder
{
    public function run(): void
    {
        $faculties = [
            ['faculty_id' => 'f_fot', 'faculty_code' => 'FOT', 'faculty_name' => 'Faculty of Technology'],
            ['faculty_id' => 'f_fas', 'faculty_code' => 'FAS', 'faculty_name' => 'Faculty of Applied Sciences'],
            ['faculty_id' => 'f_fms', 'faculty_code' => 'FMS', 'faculty_name' => 'Faculty of Management Studies'],
            ['faculty_id' => 'f_foa', 'faculty_code' => 'FOA', 'faculty_name' => 'Faculty of Agriculture'],
            ['faculty_id' => 'f_fmas', 'faculty_code' => 'FMAS', 'faculty_name' => 'Faculty of Medicine and Allied Sciences'],
            ['faculty_id' => 'f_fssh', 'faculty_code' => 'FSSH', 'faculty_name' => 'Faculty of Social Sciences and Humanities'],
        ];

        foreach ($faculties as $f) {
            Faculty::updateOrCreate(['faculty_id' => $f['faculty_id']], $f);
        }

        $departments = [
            ['department_id' => 'd_ict', 'faculty_id' => 'f_fot', 'department_code' => 'ICT', 'department_name' => 'Department of Information & Communication Technology'],
            ['department_id' => 'd_bpt', 'faculty_id' => 'f_fot', 'department_code' => 'BPT', 'department_name' => 'Department of Bio-Process Technology'],
            ['department_id' => 'd_emt', 'faculty_id' => 'f_fot', 'department_code' => 'EMT', 'department_name' => 'Department of Electrical & Media Technology'],
            ['department_id' => 'd_cs',  'faculty_id' => 'f_fas', 'department_code' => 'CS',  'department_name' => 'Department of Computing'],
            ['department_id' => 'd_ps',  'faculty_id' => 'f_fas', 'department_code' => 'PS',  'department_name' => 'Department of Physical Sciences'],
            ['department_id' => 'd_acc', 'faculty_id' => 'f_fms', 'department_code' => 'ACC', 'department_name' => 'Department of Accountancy & Finance'],
        ];

        foreach ($departments as $d) {
            Department::updateOrCreate(['department_id' => $d['department_id']], $d);
        }
    }
}
