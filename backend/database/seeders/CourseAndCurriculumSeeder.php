<?php

namespace Database\Seeders;

use App\Models\Course;
use App\Models\CoursePrerequisite;
use App\Models\CurriculumCourse;
use Illuminate\Database\Seeder;

class CourseAndCurriculumSeeder extends Seeder
{
    public function run(): void
    {
        $courses = [
            ['course_id' => 'c101', 'course_code' => 'ICT 1201', 'course_title' => 'Programming Fundamentals', 'description' => 'Introduction to C, arrays, functions, logic.', 'credit_value' => 2, 'course_level' => 1, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c102', 'course_code' => 'ICT 1202', 'course_title' => 'Database Management Systems', 'description' => 'Relational model, SQL queries, normalization.', 'credit_value' => 3, 'course_level' => 1, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c201', 'course_code' => 'ICT 2203', 'course_title' => 'Object Oriented Programming', 'description' => 'Java, Dart, OOP concepts, inheritance.', 'credit_value' => 3, 'course_level' => 2, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c301', 'course_code' => 'ICT 3102', 'course_title' => 'Software Engineering', 'description' => 'Agile, SDLC, requirements, testing.', 'credit_value' => 3, 'course_level' => 3, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c302', 'course_code' => 'ICT 3205', 'course_title' => 'UI/UX Design with Figma', 'description' => 'User research, wireframing, interactive prototyping.', 'credit_value' => 3, 'course_level' => 3, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c303', 'course_code' => 'ICT 3210', 'course_title' => 'Framer & Web Development', 'description' => 'Frontend engineering, responsiveness, animations.', 'credit_value' => 3, 'course_level' => 3, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c304', 'course_code' => 'ICT 3212', 'course_title' => 'Artificial Intelligence & ML', 'description' => 'Supervised learning, neural networks, vision.', 'credit_value' => 3, 'course_level' => 3, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c305', 'course_code' => 'ICT 3215', 'course_title' => 'Cloud Computing & DevOps', 'description' => 'Docker, Kubernetes, AWS, CI/CD pipelines.', 'credit_value' => 3, 'course_level' => 3, 'owning_department_id' => 'd_ict'],
            ['course_id' => 'c306', 'course_code' => 'ICT 3220', 'course_title' => 'Mobile Application Dev', 'description' => 'Flutter cross-platform app development.', 'credit_value' => 3, 'course_level' => 3, 'owning_department_id' => 'd_ict'],
        ];

        foreach ($courses as $c) {
            Course::updateOrCreate(['course_id' => $c['course_id']], $c);
        }

        // Prerequisites
        $prerequisites = [
            ['prerequisite_id' => 'pr_1', 'course_id' => 'c102', 'prerequisite_course_id' => 'c101', 'minimum_grade' => 'C', 'rule_type' => 'STRICT'],
            ['prerequisite_id' => 'pr_2', 'course_id' => 'c201', 'prerequisite_course_id' => 'c101', 'minimum_grade' => 'C', 'rule_type' => 'STRICT'],
            ['prerequisite_id' => 'pr_3', 'course_id' => 'c301', 'prerequisite_course_id' => 'c201', 'minimum_grade' => 'C', 'rule_type' => 'STRICT'],
        ];

        foreach ($prerequisites as $p) {
            CoursePrerequisite::updateOrCreate(['prerequisite_id' => $p['prerequisite_id']], $p);
        }

        // Curriculum Courses Mapping
        $curriculumCourses = [
            ['curriculum_course_id' => 'cc_101', 'curriculum_id' => 'curr_2024', 'course_id' => 'c101', 'semester_number' => 1, 'course_type' => 'COMPULSORY', 'is_compulsory' => true],
            ['curriculum_course_id' => 'cc_102', 'curriculum_id' => 'curr_2024', 'course_id' => 'c102', 'semester_number' => 2, 'course_type' => 'COMPULSORY', 'is_compulsory' => true],
            ['curriculum_course_id' => 'cc_201', 'curriculum_id' => 'curr_2024', 'course_id' => 'c201', 'semester_number' => 3, 'course_type' => 'COMPULSORY', 'is_compulsory' => true],
            ['curriculum_course_id' => 'cc_301', 'curriculum_id' => 'curr_2024', 'course_id' => 'c301', 'semester_number' => 5, 'course_type' => 'COMPULSORY', 'is_compulsory' => true],
            ['curriculum_course_id' => 'cc_302', 'curriculum_id' => 'curr_2024', 'course_id' => 'c302', 'semester_number' => 5, 'course_type' => 'ELECTIVE',   'is_compulsory' => false],
            ['curriculum_course_id' => 'cc_303', 'curriculum_id' => 'curr_2024', 'course_id' => 'c303', 'semester_number' => 5, 'course_type' => 'ELECTIVE',   'is_compulsory' => false],
            ['curriculum_course_id' => 'cc_304', 'curriculum_id' => 'curr_2024', 'course_id' => 'c304', 'semester_number' => 5, 'course_type' => 'ELECTIVE',   'is_compulsory' => false],
            ['curriculum_course_id' => 'cc_305', 'curriculum_id' => 'curr_2024', 'course_id' => 'c305', 'semester_number' => 5, 'course_type' => 'ELECTIVE',   'is_compulsory' => false],
            ['curriculum_course_id' => 'cc_306', 'curriculum_id' => 'curr_2024', 'course_id' => 'c306', 'semester_number' => 5, 'course_type' => 'COMPULSORY', 'is_compulsory' => true],
        ];

        foreach ($curriculumCourses as $cc) {
            CurriculumCourse::updateOrCreate(['curriculum_course_id' => $cc['curriculum_course_id']], $cc);
        }
    }
}
