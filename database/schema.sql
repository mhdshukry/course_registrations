-- =============================================================================
-- RUSL SMART COURSE REGISTRATION AND ACADEMIC MANAGEMENT SYSTEM
-- RAJARATA UNIVERSITY OF SRI LANKA (RUSL) - COMPLETE DATABASE SCHEMA
-- Compatible with PostgreSQL / MySQL / MariaDB / SQLite
-- =============================================================================

-- Database Name: rusl_course_registration_db
CREATE DATABASE IF NOT EXISTS rusl_course_registration_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE rusl_course_registration_db;

-- -----------------------------------------------------------------------------
-- 1. UNIVERSITY STRUCTURE TABLES
-- -----------------------------------------------------------------------------

CREATE TABLE faculties (
    faculty_id VARCHAR(36) PRIMARY KEY,
    faculty_code VARCHAR(10) NOT NULL UNIQUE, -- FOT, FAS, FMS, FOA, FMAS, FSSH
    faculty_name VARCHAR(150) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE departments (
    department_id VARCHAR(36) PRIMARY KEY,
    faculty_id VARCHAR(36) NOT NULL,
    department_code VARCHAR(10) NOT NULL,
    department_name VARCHAR(150) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id) ON DELETE CASCADE,
    UNIQUE (faculty_id, department_code)
);

CREATE TABLE programmes (
    programme_id VARCHAR(36) PRIMARY KEY,
    department_id VARCHAR(36) NOT NULL,
    programme_code VARCHAR(15) NOT NULL UNIQUE, -- e.g. BICT_HONS, BSC_APP_SCI
    programme_name VARCHAR(200) NOT NULL,
    degree_type VARCHAR(50) NOT NULL, -- Bachelor of Honours, Diploma, MSc
    duration_years INT NOT NULL DEFAULT 4,
    total_credits INT NOT NULL DEFAULT 120,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

CREATE TABLE academic_years (
    academic_year_id VARCHAR(36) PRIMARY KEY,
    year_name VARCHAR(20) NOT NULL UNIQUE, -- e.g. "2025/2026"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'UPCOMING', -- ACTIVE, COMPLETED, UPCOMING
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE semesters (
    semester_id VARCHAR(36) PRIMARY KEY,
    academic_year_id VARCHAR(36) NOT NULL,
    semester_number INT NOT NULL, -- 1 or 2
    semester_name VARCHAR(50) NOT NULL, -- e.g. "Semester 1"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'PLANNED', -- OPEN, CLOSED, PLANNED
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(academic_year_id) ON DELETE CASCADE,
    UNIQUE (academic_year_id, semester_number)
);

-- -----------------------------------------------------------------------------
-- 2. USER AND ACCESS CONTROL TABLES
-- -----------------------------------------------------------------------------

CREATE TABLE users (
    user_id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    account_status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, SUSPENDED, DEACTIVATED
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    role_id VARCHAR(36) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE -- STUDENT, HEAD_OF_DEPARTMENT, ASSISTANT_REGISTRAR, SYSTEM_ADMIN
);

CREATE TABLE user_roles (
    user_role_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    role_id VARCHAR(36) NOT NULL,
    faculty_id VARCHAR(36) NULL,
    department_id VARCHAR(36) NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE students (
    student_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL UNIQUE,
    registration_number VARCHAR(30) NOT NULL UNIQUE, -- e.g. "ICT/2021/045"
    faculty_id VARCHAR(36) NOT NULL,
    department_id VARCHAR(36) NOT NULL,
    programme_id VARCHAR(36) NOT NULL,
    curriculum_id VARCHAR(36) NOT NULL,
    intake_year INT NOT NULL, -- e.g. 2021
    current_level INT NOT NULL DEFAULT 1, -- 1, 2, 3, 4
    academic_status VARCHAR(30) DEFAULT 'GOOD_STANDING', -- GOOD_STANDING, PROBATION, SUSPENDED
    registration_eligibility BOOLEAN DEFAULT TRUE,
    min_credits INT DEFAULT 12,
    max_credits INT DEFAULT 24,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (programme_id) REFERENCES programmes(programme_id)
);

CREATE TABLE staff (
    staff_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL UNIQUE,
    employee_number VARCHAR(30) NOT NULL UNIQUE,
    faculty_id VARCHAR(36) NOT NULL,
    department_id VARCHAR(36) NOT NULL,
    designation VARCHAR(100) NOT NULL, -- Senior Lecturer, Professor, AR, HoD
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- -----------------------------------------------------------------------------
-- 3. CURRICULUM & COURSE MANAGEMENT TABLES
-- -----------------------------------------------------------------------------

CREATE TABLE curricula (
    curriculum_id VARCHAR(36) PRIMARY KEY,
    programme_id VARCHAR(36) NOT NULL,
    curriculum_name VARCHAR(150) NOT NULL, -- e.g. "BICT Curriculum 2024"
    version VARCHAR(20) NOT NULL, -- "v2.1"
    effective_year INT NOT NULL,
    total_credits INT NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, SUPERSEDED, DRAFT
    FOREIGN KEY (programme_id) REFERENCES programmes(programme_id) ON DELETE CASCADE
);

CREATE TABLE courses (
    course_id VARCHAR(36) PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE, -- e.g. "ICT 3102"
    course_title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    credit_value INT NOT NULL,
    course_level INT NOT NULL, -- 1, 2, 3, 4
    owning_department_id VARCHAR(36) NOT NULL,
    course_status VARCHAR(20) DEFAULT 'ACTIVE',
    FOREIGN KEY (owning_department_id) REFERENCES departments(department_id)
);

CREATE TABLE curriculum_courses (
    curriculum_course_id VARCHAR(36) PRIMARY KEY,
    curriculum_id VARCHAR(36) NOT NULL,
    course_id VARCHAR(36) NOT NULL,
    semester_number INT NOT NULL,
    course_type VARCHAR(20) NOT NULL, -- COMPULSORY, ELECTIVE, OPTIONAL, REPEAT, NON_CREDIT, AUDIT
    is_compulsory BOOLEAN DEFAULT TRUE,
    elective_group_id VARCHAR(36) NULL,
    FOREIGN KEY (curriculum_id) REFERENCES curricula(curriculum_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE TABLE course_prerequisites (
    prerequisite_id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL,
    prerequisite_course_id VARCHAR(36) NOT NULL,
    minimum_grade VARCHAR(5) DEFAULT 'C',
    rule_type VARCHAR(20) DEFAULT 'STRICT', -- STRICT, WAIVABLE
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE (course_id, prerequisite_course_id)
);

CREATE TABLE course_corequisites (
    corequisite_id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL,
    corequisite_course_id VARCHAR(36) NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (corequisite_course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE TABLE course_equivalencies (
    equivalency_id VARCHAR(36) PRIMARY KEY,
    old_course_id VARCHAR(36) NOT NULL,
    new_course_id VARCHAR(36) NOT NULL,
    equivalency_type VARCHAR(30) DEFAULT 'DIRECT_REPLACEMENT',
    effective_date DATE NOT NULL,
    FOREIGN KEY (old_course_id) REFERENCES courses(course_id),
    FOREIGN KEY (new_course_id) REFERENCES courses(course_id)
);

-- -----------------------------------------------------------------------------
-- 4. COURSE OFFERINGS & TIMETABLE TABLES
-- -----------------------------------------------------------------------------

CREATE TABLE course_offerings (
    offering_id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL,
    academic_year_id VARCHAR(36) NOT NULL,
    semester_id VARCHAR(36) NOT NULL,
    department_id VARCHAR(36) NOT NULL,
    lecturer_id VARCHAR(36) NULL,
    capacity INT NOT NULL DEFAULT 60,
    registration_count INT NOT NULL DEFAULT 0,
    delivery_mode VARCHAR(20) DEFAULT 'PHYSICAL', -- PHYSICAL, ONLINE, HYBRID
    offering_status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, CLOSED, CANCELLED
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(academic_year_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
    FOREIGN KEY (lecturer_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

CREATE TABLE course_groups (
    group_id VARCHAR(36) PRIMARY KEY,
    offering_id VARCHAR(36) NOT NULL,
    group_name VARCHAR(50) NOT NULL, -- e.g. "Lecture Group A", "Lab Group 1"
    group_type VARCHAR(20) NOT NULL, -- LECTURE, PRACTICAL, TUTORIAL, LAB
    maximum_capacity INT NOT NULL,
    FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id) ON DELETE CASCADE
);

CREATE TABLE timetable_slots (
    timetable_slot_id VARCHAR(36) PRIMARY KEY,
    group_id VARCHAR(36) NOT NULL,
    day_of_week VARCHAR(15) NOT NULL, -- Monday, Tuesday, Wednesday, Thursday, Friday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    venue VARCHAR(100) NOT NULL,
    FOREIGN KEY (group_id) REFERENCES course_groups(group_id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 5. REGISTRATION & WORKFLOW TABLES
-- -----------------------------------------------------------------------------

CREATE TABLE registrations (
    registration_id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    academic_year_id VARCHAR(36) NOT NULL,
    semester_id VARCHAR(36) NOT NULL,
    total_credits INT NOT NULL DEFAULT 0,
    registration_status VARCHAR(30) DEFAULT 'DRAFT', -- DRAFT, SUBMITTED, CHANGES_REQUESTED, HOD_APPROVED, FACULTY_APPROVED, REGISTERED, LOCKED
    submitted_at TIMESTAMP NULL,
    approved_at TIMESTAMP NULL,
    locked_at TIMESTAMP NULL,
    verification_code VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(academic_year_id),
    FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
    UNIQUE (student_id, academic_year_id, semester_id)
);

CREATE TABLE registration_courses (
    registration_course_id VARCHAR(36) PRIMARY KEY,
    registration_id VARCHAR(36) NOT NULL,
    offering_id VARCHAR(36) NOT NULL,
    group_id VARCHAR(36) NULL,
    registration_type VARCHAR(20) DEFAULT 'NORMAL', -- NORMAL, REPEAT, AUDIT, SUBSTITUTE, SPECIAL
    course_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, DROPPED
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dropped_at TIMESTAMP NULL,
    FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE,
    FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES course_groups(group_id)
);

CREATE TABLE registration_approvals (
    approval_id VARCHAR(36) PRIMARY KEY,
    registration_id VARCHAR(36) NOT NULL,
    approver_user_id VARCHAR(36) NOT NULL,
    approval_level VARCHAR(30) NOT NULL, -- HOD, DEAN, FACULTY_AR, SYSTEM_ADMIN
    decision VARCHAR(20) NOT NULL, -- APPROVED, REJECTED, CHANGES_REQUESTED
    comments TEXT NULL,
    decided_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE,
    FOREIGN KEY (approver_user_id) REFERENCES users(user_id)
);

CREATE TABLE registration_changes (
    change_id VARCHAR(36) PRIMARY KEY,
    registration_id VARCHAR(36) NOT NULL,
    changed_by_user_id VARCHAR(36) NOT NULL,
    previous_value TEXT NOT NULL,
    new_value TEXT NOT NULL,
    reason TEXT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by_user_id) REFERENCES users(user_id)
);

-- -----------------------------------------------------------------------------
-- 6. SPECIAL REQUESTS, WAITING LISTS & AUDIT LOGS
-- -----------------------------------------------------------------------------

CREATE TABLE special_requests (
    request_id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    registration_id VARCHAR(36) NULL,
    request_type VARCHAR(30) NOT NULL, -- OVERLOAD, PREREQUISITE_WAIVER, LATE_REGISTRATION, TIMETABLE_CLASH, SUBSTITUTION
    reason TEXT NOT NULL,
    attachment_url VARCHAR(255) NULL,
    request_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (registration_id) REFERENCES registrations(registration_id) ON DELETE SET NULL
);

CREATE TABLE request_approvals (
    request_approval_id VARCHAR(36) PRIMARY KEY,
    request_id VARCHAR(36) NOT NULL,
    reviewer_user_id VARCHAR(36) NOT NULL,
    decision VARCHAR(20) NOT NULL, -- APPROVED, REJECTED
    comments TEXT NULL,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES special_requests(request_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_user_id) REFERENCES users(user_id)
);

CREATE TABLE waiting_lists (
    waiting_list_id VARCHAR(36) PRIMARY KEY,
    offering_id VARCHAR(36) NOT NULL,
    student_id VARCHAR(36) NOT NULL,
    position INT NOT NULL,
    status VARCHAR(20) DEFAULT 'WAITING', -- WAITING, PROMOTED, EXPIRED, CANCELLED
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    UNIQUE (offering_id, student_id)
);

CREATE TABLE notifications (
    notification_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    notification_type VARCHAR(30) NOT NULL, -- STATUS_CHANGE, DEADLINE_ALERT, WAITING_LIST_SEAT, REVIEW_COMMENT
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE audit_logs (
    audit_log_id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id VARCHAR(36) NOT NULL,
    old_data TEXT NULL,
    new_data TEXT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE system_settings (
    setting_id VARCHAR(36) PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    faculty_id VARCHAR(36) NULL,
    programme_id VARCHAR(36) NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id) ON DELETE CASCADE
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =============================================================================
CREATE INDEX idx_students_faculty ON students(faculty_id);
CREATE INDEX idx_students_programme ON students(programme_id);
CREATE INDEX idx_courses_code ON courses(course_code);
CREATE INDEX idx_offerings_course ON course_offerings(course_id);
CREATE INDEX idx_registrations_student ON registrations(student_id);
CREATE INDEX idx_registrations_status ON registrations(registration_status);
CREATE INDEX idx_timetable_slots_group ON timetable_slots(group_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
