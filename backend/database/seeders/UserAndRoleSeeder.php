<?php

namespace Database\Seeders;

use App\Models\Curriculum;
use App\Models\Role;
use App\Models\Staff;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserAndRoleSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Roles
        $roles = [
            ['role_id' => 'r_student',     'role_name' => 'STUDENT'],
            ['role_id' => 'r_adviser',     'role_name' => 'ACADEMIC_ADVISER'],
            ['role_id' => 'r_lecturer',    'role_name' => 'LECTURER'],
            ['role_id' => 'r_hod',         'role_name' => 'HEAD_OF_DEPARTMENT'],
            ['role_id' => 'r_coordinator', 'role_name' => 'FACULTY_COORDINATOR'],
            ['role_id' => 'r_ar',          'role_name' => 'ASSISTANT_REGISTRAR'],
            ['role_id' => 'r_central',     'role_name' => 'CENTRAL_ADMIN'],
            ['role_id' => 'r_sysadmin',    'role_name' => 'SYSTEM_ADMIN'],
        ];

        foreach ($roles as $r) {
            Role::updateOrCreate(['role_id' => $r['role_id']], $r);
        }

        $passwordHash = Hash::make('RuslPass#2026');

        // 2. Users
        $users = [
            ['user_id' => 'u_std01', 'username' => 'student_nafis',  'email' => 'student.nafis@rjt.ac.lk',   'role_id' => 'r_student',     'faculty_id' => 'f_fot', 'department_id' => 'd_ict'],
            ['user_id' => 'u_adv01', 'username' => 'adviser_chanda', 'email' => 'chandanajay@rjt.ac.lk',     'role_id' => 'r_adviser',     'faculty_id' => 'f_fot', 'department_id' => 'd_ict'],
            ['user_id' => 'u_lec01', 'username' => 'lecturer_sarah', 'email' => 'sarah.johnson@rjt.ac.lk',   'role_id' => 'r_lecturer',    'faculty_id' => 'f_fot', 'department_id' => 'd_ict'],
            ['user_id' => 'u_hod01', 'username' => 'hod_perera',     'email' => 'sarath.perera@rjt.ac.lk',   'role_id' => 'r_hod',         'faculty_id' => 'f_fot', 'department_id' => 'd_ict'],
            ['user_id' => 'u_coo01', 'username' => 'coord_kanthi',   'email' => 'kanthi.silva@rjt.ac.lk',    'role_id' => 'r_coordinator', 'faculty_id' => 'f_fot', 'department_id' => 'd_ict'],
            ['user_id' => 'u_ar001', 'username' => 'ar_dilhani',     'email' => 'ar.fot@rjt.ac.lk',          'role_id' => 'r_ar',          'faculty_id' => 'f_fot', 'department_id' => null],
            ['user_id' => 'u_cen01', 'username' => 'central_admin',  'email' => 'registration@rjt.ac.lk',    'role_id' => 'r_central',     'faculty_id' => null,    'department_id' => null],
            ['user_id' => 'u_sys01', 'username' => 'sys_admin',      'email' => 'itcenter@rjt.ac.lk',        'role_id' => 'r_sysadmin',    'faculty_id' => null,    'department_id' => null],
        ];

        foreach ($users as $u) {
            User::updateOrCreate(
                ['user_id' => $u['user_id']],
                [
                    'username' => $u['username'],
                    'email' => $u['email'],
                    'password_hash' => $passwordHash,
                    'account_status' => 'ACTIVE',
                ]
            );

            DB::table('user_roles')->updateOrInsert(
                ['user_role_id' => 'ur_' . $u['user_id']],
                [
                    'user_id' => $u['user_id'],
                    'role_id' => $u['role_id'],
                    'faculty_id' => $u['faculty_id'],
                    'department_id' => $u['department_id'],
                ]
            );
        }

        // 3. Curriculum
        $curriculum = Curriculum::updateOrCreate(
            ['curriculum_id' => 'curr_2024'],
            [
                'programme_id' => 'p_bict',
                'curriculum_name' => 'BICT Curriculum 2024',
                'version' => 'v2.1',
                'effective_year' => 2024,
                'total_credits' => 120,
                'status' => 'ACTIVE',
            ]
        );

        // 4. Student Profile for student_nafis
        Student::updateOrCreate(
            ['student_id' => 'st_nafis'],
            [
                'user_id' => 'u_std01',
                'registration_number' => 'ICT/2021/045',
                'faculty_id' => 'f_fot',
                'department_id' => 'd_ict',
                'programme_id' => 'p_bict',
                'curriculum_id' => $curriculum->curriculum_id,
                'intake_year' => 2021,
                'current_level' => 3,
                'academic_status' => 'GOOD_STANDING',
                'registration_eligibility' => true,
                'min_credits' => 12,
                'max_credits' => 24,
            ]
        );

        // 5. Staff Profiles
        $staffMembers = [
            ['staff_id' => 'stf_adv', 'user_id' => 'u_adv01', 'employee_number' => 'EMP-0101', 'faculty_id' => 'f_fot', 'department_id' => 'd_ict', 'designation' => 'Senior Lecturer & Academic Adviser'],
            ['staff_id' => 'stf_lec', 'user_id' => 'u_lec01', 'employee_number' => 'EMP-0102', 'faculty_id' => 'f_fot', 'department_id' => 'd_ict', 'designation' => 'Lecturer (Probationary)'],
            ['staff_id' => 'stf_hod', 'user_id' => 'u_hod01', 'employee_number' => 'EMP-0100', 'faculty_id' => 'f_fot', 'department_id' => 'd_ict', 'designation' => 'Head of Department / Associate Prof'],
            ['staff_id' => 'stf_coo', 'user_id' => 'u_coo01', 'employee_number' => 'EMP-0103', 'faculty_id' => 'f_fot', 'department_id' => 'd_ict', 'designation' => 'Faculty Academic Coordinator'],
            ['staff_id' => 'stf_ar',  'user_id' => 'u_ar001', 'employee_number' => 'EMP-0010', 'faculty_id' => 'f_fot', 'department_id' => 'd_ict', 'designation' => 'Assistant Registrar (Faculty)'],
        ];

        foreach ($staffMembers as $s) {
            Staff::updateOrCreate(['staff_id' => $s['staff_id']], $s);
        }
    }
}
