-- =============================================================================
-- RAJARATA UNIVERSITY OF SRI LANKA (RUSL) - SEED DATA & TEST CREDENTIALS
-- Database Population Script for Course Registration & Academic System
-- Database Name: rusl_course_registration_db
-- =============================================================================

USE rusl_course_registration_db;

-- -----------------------------------------------------------------------------
-- 1. FACULTIES SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO faculties (faculty_id, faculty_code, faculty_name, status) VALUES
('f_fot', 'FOT', 'Faculty of Technology', 'ACTIVE'),
('f_fas', 'FAS', 'Faculty of Applied Sciences', 'ACTIVE'),
('f_fms', 'FMS', 'Faculty of Management Studies', 'ACTIVE'),
('f_foa', 'FOA', 'Faculty of Agriculture', 'ACTIVE'),
('f_fmas', 'FMAS', 'Faculty of Medicine and Allied Sciences', 'ACTIVE'),
('f_fssh', 'FSSH', 'Faculty of Social Sciences and Humanities', 'ACTIVE');

-- -----------------------------------------------------------------------------
-- 2. DEPARTMENTS SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO departments (department_id, faculty_id, department_code, department_name, status) VALUES
('d_ict', 'f_fot', 'ICT', 'Department of Information & Communication Technology', 'ACTIVE'),
('d_bpt', 'f_fot', 'BPT', 'Department of Bio-Process Technology', 'ACTIVE'),
('d_emt', 'f_fot', 'EMT', 'Department of Electrical & Media Technology', 'ACTIVE'),
('d_cs',  'f_fas', 'CS',  'Department of Computing', 'ACTIVE'),
('d_ps',  'f_fas', 'PS',  'Department of Physical Sciences', 'ACTIVE'),
('d_acc', 'f_fms', 'ACC', 'Department of Accountancy & Finance', 'ACTIVE');

-- -----------------------------------------------------------------------------
-- 3. DEGREE PROGRAMMES SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO programmes (programme_id, department_id, programme_code, programme_name, degree_type, duration_years, total_credits, status) VALUES
('p_bict', 'd_ict', 'BICT_HONS', 'Bachelor of Information and Communication Technology Honours', 'BSc Honours', 4, 120, 'ACTIVE'),
('p_bpt',  'd_bpt', 'BBPT_HONS', 'Bachelor of Bio-Process Technology Honours', 'BSc Honours', 4, 120, 'ACTIVE'),
('p_cs',   'd_cs',  'BSCCS_HONS', 'Bachelor of Science Honours in Computer Science', 'BSc Honours', 4, 120, 'ACTIVE'),
('p_bba',  'd_acc', 'BBA_HONS',  'Bachelor of Business Administration Honours', 'BBA Honours', 4, 120, 'ACTIVE');

-- -----------------------------------------------------------------------------
-- 4. ACADEMIC YEARS & SEMESTERS SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO academic_years (academic_year_id, year_name, start_date, end_date, status) VALUES
('ay_2025', '2025/2026', '2025-09-01', '2026-08-31', 'ACTIVE');

INSERT INTO semesters (semester_id, academic_year_id, semester_number, semester_name, start_date, end_date, status) VALUES
('sem_5', 'ay_2025', 1, 'Semester 5 (Level 3 Sem 1)', '2026-02-01', '2026-07-31', 'OPEN');

-- -----------------------------------------------------------------------------
-- 5. ROLES SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO roles (role_id, role_name) VALUES
('r_student',     'STUDENT'),
('r_adviser',     'ACADEMIC_ADVISER'),
('r_lecturer',    'LECTURER'),
('r_hod',         'HEAD_OF_DEPARTMENT'),
('r_coordinator', 'FACULTY_COORDINATOR'),
('r_ar',          'ASSISTANT_REGISTRAR'),
('r_central',     'CENTRAL_ADMIN'),
('r_sysadmin',    'SYSTEM_ADMIN');

-- -----------------------------------------------------------------------------
-- 6. USERS & CREDENTIALS SEED DATA (Default Password for all demo accounts: RuslPass#2026)
-- -----------------------------------------------------------------------------
INSERT INTO users (user_id, username, email, password_hash, account_status) VALUES
('u_std01', 'student_nafis',  'student.nafis@rjt.ac.lk',   '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_adv01', 'adviser_chanda', 'chandanajay@rjt.ac.lk',     '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_lec01', 'lecturer_sarah', 'sarah.johnson@rjt.ac.lk',   '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_hod01', 'hod_perera',     'sarath.perera@rjt.ac.lk',   '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_coo01', 'coord_kanthi',   'kanthi.silva@rjt.ac.lk',    '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_ar001', 'ar_dilhani',     'ar.fot@rjt.ac.lk',          '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_cen01', 'central_admin',  'registration@rjt.ac.lk',    '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE'),
('u_sys01', 'sys_admin',      'itcenter@rjt.ac.lk',        '$2a$12$eImiTXuWVxfM37uY4JANjO5a6R8f... (RuslPass#2026)', 'ACTIVE');

-- Assign User Roles
INSERT INTO user_roles (user_role_id, user_id, role_id, faculty_id, department_id) VALUES
('ur_1', 'u_std01', 'r_student',     'f_fot', 'd_ict'),
('ur_2', 'u_adv01', 'r_adviser',     'f_fot', 'd_ict'),
('ur_3', 'u_lec01', 'r_lecturer',    'f_fot', 'd_ict'),
('ur_4', 'u_hod01', 'r_hod',         'f_fot', 'd_ict'),
('ur_5', 'u_coo01', 'r_coordinator', 'f_fot', 'd_ict'),
('ur_6', 'u_ar001', 'r_ar',          'f_fot', NULL),
('ur_7', 'u_cen01', 'r_central',     NULL,    NULL),
('ur_8', 'u_sys01', 'r_sysadmin',    NULL,    NULL);

-- -----------------------------------------------------------------------------
-- 7. STUDENT PROFILE SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO curricula (curriculum_id, programme_id, curriculum_name, version, effective_year, total_credits, status) VALUES
('curr_2024', 'p_bict', 'BICT Curriculum 2024', 'v2.1', 2024, 120, 'ACTIVE');

INSERT INTO students (student_id, user_id, registration_number, faculty_id, department_id, programme_id, curriculum_id, intake_year, current_level, academic_status, registration_eligibility, min_credits, max_credits) VALUES
('st_nafis', 'u_std01', 'ICT/2021/045', 'f_fot', 'd_ict', 'p_bict', 'curr_2024', 2021, 3, 'GOOD_STANDING', TRUE, 12, 24);

-- -----------------------------------------------------------------------------
-- 8. COURSES CATALOG SEED DATA
-- -----------------------------------------------------------------------------
INSERT INTO courses (course_id, course_code, course_title, description, credit_value, course_level, owning_department_id, course_status) VALUES
('c101', 'ICT 1201', 'Programming Fundamentals', 'Introduction to C, arrays, functions, logic.', 2, 1, 'd_ict', 'ACTIVE'),
('c102', 'ICT 1202', 'Database Management Systems', 'Relational model, SQL queries, normalization.', 3, 1, 'd_ict', 'ACTIVE'),
('c201', 'ICT 2203', 'Object Oriented Programming', 'Java, Dart, OOP concepts, inheritance.', 3, 2, 'd_ict', 'ACTIVE'),
('c301', 'ICT 3102', 'Software Engineering', 'Agile, SDLC, requirements, testing.', 3, 3, 'd_ict', 'ACTIVE'),
('c302', 'ICT 3205', 'UI/UX Design with Figma', 'User research, wireframing, interactive prototyping.', 3, 3, 'd_ict', 'ACTIVE'),
('c303', 'ICT 3210', 'Framer & Web Development', 'Frontend engineering, responsiveness, animations.', 3, 3, 'd_ict', 'ACTIVE'),
('c304', 'ICT 3212', 'Artificial Intelligence & ML', 'Supervised learning, neural networks, vision.', 3, 3, 'd_ict', 'ACTIVE'),
('c305', 'ICT 3215', 'Cloud Computing & DevOps', 'Docker, Kubernetes, AWS, CI/CD pipelines.', 3, 3, 'd_ict', 'ACTIVE'),
('c306', 'ICT 3220', 'Mobile Application Dev', 'Flutter cross-platform app development.', 3, 3, 'd_ict', 'ACTIVE');

-- Prerequisites mapping
INSERT INTO course_prerequisites (prerequisite_id, course_id, prerequisite_course_id, minimum_grade, rule_type) VALUES
('pr_1', 'c102', 'c101', 'C', 'STRICT'),
('pr_2', 'c201', 'c101', 'C', 'STRICT'),
('pr_3', 'c301', 'c201', 'C', 'STRICT');
