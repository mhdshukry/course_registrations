-- RUSL Course Registration System - production relational schema
-- Target: MySQL 8.0+ / MariaDB 10.4+
-- Safe installation: creates a versioned database and does not overwrite the old prototype.

CREATE DATABASE IF NOT EXISTS rusl_course_registration_v2
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rusl_course_registration_v2;

CREATE TABLE IF NOT EXISTS faculties (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(12) NOT NULL UNIQUE,
  name VARCHAR(180) NOT NULL UNIQUE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS departments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  faculty_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(16) NOT NULL,
  name VARCHAR(180) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_departments_faculty FOREIGN KEY (faculty_id) REFERENCES faculties(id),
  CONSTRAINT uq_departments_faculty_code UNIQUE (faculty_id, code),
  INDEX idx_departments_faculty (faculty_id, is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS programmes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  department_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(24) NOT NULL UNIQUE,
  name VARCHAR(220) NOT NULL,
  degree_type VARCHAR(100) NOT NULL,
  duration_years TINYINT UNSIGNED NOT NULL,
  minimum_credits SMALLINT UNSIGNED NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_programme_duration CHECK (duration_years BETWEEN 1 AND 8),
  CONSTRAINT ck_programme_credits CHECK (minimum_credits > 0),
  CONSTRAINT fk_programmes_department FOREIGN KEY (department_id) REFERENCES departments(id),
  INDEX idx_programmes_department (department_id, is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  display_name VARCHAR(180) NOT NULL,
  status ENUM('ACTIVE','SUSPENDED','DISABLED') NOT NULL DEFAULT 'ACTIVE',
  last_login_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_roles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  role_code ENUM('STUDENT','HOD','ASSISTANT_REGISTRAR','DEAN','SUPER_ADMIN') NOT NULL,
  faculty_id BIGINT UNSIGNED NULL,
  department_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_roles_faculty FOREIGN KEY (faculty_id) REFERENCES faculties(id),
  CONSTRAINT fk_user_roles_department FOREIGN KEY (department_id) REFERENCES departments(id),
  CONSTRAINT uq_user_role_scope UNIQUE (user_id, role_code, faculty_id, department_id),
  INDEX idx_user_roles_scope (role_code, faculty_id, department_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS curricula (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  programme_id BIGINT UNSIGNED NOT NULL,
  version VARCHAR(30) NOT NULL,
  effective_from_year SMALLINT UNSIGNED NOT NULL,
  minimum_credits SMALLINT UNSIGNED NOT NULL,
  status ENUM('DRAFT','ACTIVE','SUPERSEDED') NOT NULL DEFAULT 'DRAFT',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_curricula_programme FOREIGN KEY (programme_id) REFERENCES programmes(id),
  CONSTRAINT uq_curriculum_version UNIQUE (programme_id, version)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS students (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  registration_number VARCHAR(40) NOT NULL UNIQUE,
  faculty_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NOT NULL,
  programme_id BIGINT UNSIGNED NOT NULL,
  curriculum_id BIGINT UNSIGNED NOT NULL,
  intake_year SMALLINT UNSIGNED NOT NULL,
  current_level TINYINT UNSIGNED NOT NULL DEFAULT 1,
  current_semester TINYINT UNSIGNED NOT NULL DEFAULT 1,
  min_semester_credits TINYINT UNSIGNED NOT NULL DEFAULT 12,
  max_semester_credits TINYINT UNSIGNED NOT NULL DEFAULT 24,
  academic_status ENUM('GOOD_STANDING','PROBATION','SUSPENDED','COMPLETED','WITHDRAWN') NOT NULL DEFAULT 'GOOD_STANDING',
  is_registration_eligible BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  CONSTRAINT ck_student_level CHECK (current_level BETWEEN 1 AND 8),
  CONSTRAINT ck_student_semester CHECK (current_semester BETWEEN 1 AND 2),
  CONSTRAINT ck_student_credit_range CHECK (min_semester_credits <= max_semester_credits),
  CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_students_faculty FOREIGN KEY (faculty_id) REFERENCES faculties(id),
  CONSTRAINT fk_students_department FOREIGN KEY (department_id) REFERENCES departments(id),
  CONSTRAINT fk_students_programme FOREIGN KEY (programme_id) REFERENCES programmes(id),
  CONSTRAINT fk_students_curriculum FOREIGN KEY (curriculum_id) REFERENCES curricula(id),
  INDEX idx_students_registry (faculty_id, department_id, programme_id, academic_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS staff (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL UNIQUE,
  employee_number VARCHAR(40) NOT NULL UNIQUE,
  faculty_id BIGINT UNSIGNED NULL,
  department_id BIGINT UNSIGNED NULL,
  designation VARCHAR(120) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_staff_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_staff_faculty FOREIGN KEY (faculty_id) REFERENCES faculties(id),
  CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS academic_years (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) NOT NULL UNIQUE,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,
  status ENUM('PLANNED','ACTIVE','COMPLETED') NOT NULL DEFAULT 'PLANNED',
  CONSTRAINT ck_academic_year_dates CHECK (ends_on > starts_on)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS semesters (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  academic_year_id BIGINT UNSIGNED NOT NULL,
  semester_number TINYINT UNSIGNED NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,
  status ENUM('PLANNED','OPEN','CLOSED') NOT NULL DEFAULT 'PLANNED',
  CONSTRAINT ck_semester_number CHECK (semester_number IN (1,2)),
  CONSTRAINT ck_semester_dates CHECK (ends_on > starts_on),
  CONSTRAINT fk_semesters_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
  CONSTRAINT uq_semester_year_number UNIQUE (academic_year_id, semester_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS registration_periods (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  semester_id BIGINT UNSIGNED NOT NULL,
  faculty_id BIGINT UNSIGNED NULL,
  opens_at DATETIME NOT NULL,
  closes_at DATETIME NOT NULL,
  late_closes_at DATETIME NULL,
  is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_by BIGINT UNSIGNED NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_registration_period CHECK (closes_at > opens_at),
  CONSTRAINT fk_period_semester FOREIGN KEY (semester_id) REFERENCES semesters(id),
  CONSTRAINT fk_period_faculty FOREIGN KEY (faculty_id) REFERENCES faculties(id),
  CONSTRAINT fk_period_creator FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT uq_period_scope UNIQUE (semester_id, faculty_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  department_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(24) NOT NULL UNIQUE,
  title VARCHAR(220) NOT NULL,
  description TEXT NULL,
  credits TINYINT UNSIGNED NOT NULL,
  level TINYINT UNSIGNED NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_course_credits CHECK (credits BETWEEN 0 AND 30),
  CONSTRAINT ck_course_level CHECK (level BETWEEN 1 AND 8),
  CONSTRAINT fk_courses_department FOREIGN KEY (department_id) REFERENCES departments(id),
  INDEX idx_courses_department_level (department_id, level, is_active)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS curriculum_courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  curriculum_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  level TINYINT UNSIGNED NOT NULL,
  semester_number TINYINT UNSIGNED NOT NULL,
  requirement_type ENUM('COMPULSORY','OPTIONAL') NOT NULL,
  elective_group VARCHAR(50) NULL,
  CONSTRAINT fk_curriculum_courses_curriculum FOREIGN KEY (curriculum_id) REFERENCES curricula(id) ON DELETE CASCADE,
  CONSTRAINT fk_curriculum_courses_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT uq_curriculum_course UNIQUE (curriculum_id, course_id),
  INDEX idx_curriculum_plan (curriculum_id, level, semester_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS course_prerequisites (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  prerequisite_course_id BIGINT UNSIGNED NOT NULL,
  minimum_grade VARCHAR(4) NULL,
  is_waivable BOOLEAN NOT NULL DEFAULT FALSE,
  CONSTRAINT ck_prerequisite_not_self CHECK (course_id <> prerequisite_course_id),
  CONSTRAINT fk_prereq_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
  CONSTRAINT fk_prereq_required FOREIGN KEY (prerequisite_course_id) REFERENCES courses(id),
  CONSTRAINT uq_course_prerequisite UNIQUE (course_id, prerequisite_course_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS course_offerings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_id BIGINT UNSIGNED NOT NULL,
  semester_id BIGINT UNSIGNED NOT NULL,
  lecturer_staff_id BIGINT UNSIGNED NULL,
  capacity SMALLINT UNSIGNED NOT NULL,
  registered_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  delivery_mode ENUM('PHYSICAL','ONLINE','HYBRID') NOT NULL DEFAULT 'PHYSICAL',
  status ENUM('DRAFT','OPEN','CLOSED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  version INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_offering_capacity CHECK (registered_count <= capacity),
  CONSTRAINT fk_offering_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_offering_semester FOREIGN KEY (semester_id) REFERENCES semesters(id),
  CONSTRAINT fk_offering_lecturer FOREIGN KEY (lecturer_staff_id) REFERENCES staff(id),
  CONSTRAINT uq_course_offering UNIQUE (course_id, semester_id),
  INDEX idx_offering_semester_status (semester_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS timetable_slots (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  offering_id BIGINT UNSIGNED NOT NULL,
  activity_type ENUM('LECTURE','PRACTICAL','TUTORIAL') NOT NULL,
  group_name VARCHAR(40) NOT NULL DEFAULT 'All',
  day_of_week ENUM('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') NOT NULL,
  starts_at TIME NOT NULL,
  ends_at TIME NOT NULL,
  venue VARCHAR(120) NOT NULL,
  CONSTRAINT ck_timetable_time CHECK (ends_at > starts_at),
  CONSTRAINT fk_timetable_offering FOREIGN KEY (offering_id) REFERENCES course_offerings(id) ON DELETE CASCADE,
  INDEX idx_timetable_collision (day_of_week, venue, starts_at, ends_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS registrations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  semester_id BIGINT UNSIGNED NOT NULL,
  status ENUM('DRAFT','SUBMITTED','CHANGES_REQUESTED','HOD_APPROVED','AR_APPROVED','LOCKED','REJECTED') NOT NULL DEFAULT 'DRAFT',
  total_credits SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  verification_token CHAR(36) NOT NULL UNIQUE,
  submitted_at DATETIME NULL,
  hod_decided_at DATETIME NULL,
  ar_decided_at DATETIME NULL,
  locked_at DATETIME NULL,
  version INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_registrations_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_registrations_semester FOREIGN KEY (semester_id) REFERENCES semesters(id),
  CONSTRAINT uq_student_semester_registration UNIQUE (student_id, semester_id),
  INDEX idx_registration_queue (semester_id, status, student_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS registration_courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  registration_id BIGINT UNSIGNED NOT NULL,
  offering_id BIGINT UNSIGNED NOT NULL,
  registration_type ENUM('NORMAL','REPEAT') NOT NULL DEFAULT 'NORMAL',
  status ENUM('SELECTED','DROPPED') NOT NULL DEFAULT 'SELECTED',
  added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dropped_at DATETIME NULL,
  CONSTRAINT fk_registration_courses_registration FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE CASCADE,
  CONSTRAINT fk_registration_courses_offering FOREIGN KEY (offering_id) REFERENCES course_offerings(id),
  CONSTRAINT uq_registration_offering UNIQUE (registration_id, offering_id),
  INDEX idx_registration_courses_active (registration_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workflow_actions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  registration_id BIGINT UNSIGNED NOT NULL,
  actor_user_id BIGINT UNSIGNED NOT NULL,
  actor_role ENUM('STUDENT','HOD','ASSISTANT_REGISTRAR','DEAN','SUPER_ADMIN') NOT NULL,
  action ENUM('SUBMITTED','APPROVED','CHANGES_REQUESTED','REJECTED','LOCKED','ADMIN_OVERRIDE') NOT NULL,
  from_status VARCHAR(30) NOT NULL,
  to_status VARCHAR(30) NOT NULL,
  comments TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_workflow_registration FOREIGN KEY (registration_id) REFERENCES registrations(id) ON DELETE CASCADE,
  CONSTRAINT fk_workflow_actor FOREIGN KEY (actor_user_id) REFERENCES users(id),
  INDEX idx_workflow_registration_time (registration_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS academic_results (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  semester_id BIGINT UNSIGNED NOT NULL,
  status ENUM('COMPLETED','MEDICAL','DROPPED') NOT NULL,
  grade VARCHAR(4) NULL,
  grade_point DECIMAL(3,2) NULL,
  attempt_number TINYINT UNSIGNED NOT NULL DEFAULT 1,
  recorded_by BIGINT UNSIGNED NOT NULL,
  recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_result_grade_point CHECK (grade_point IS NULL OR grade_point BETWEEN 0 AND 4),
  CONSTRAINT fk_results_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_results_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_results_semester FOREIGN KEY (semester_id) REFERENCES semesters(id),
  CONSTRAINT fk_results_recorder FOREIGN KEY (recorded_by) REFERENCES users(id),
  CONSTRAINT uq_result_attempt UNIQUE (student_id, course_id, semester_id, attempt_number),
  INDEX idx_results_student_status (student_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS special_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id BIGINT UNSIGNED NOT NULL,
  registration_id BIGINT UNSIGNED NULL,
  type ENUM('CREDIT_OVERLOAD','PREREQUISITE_WAIVER','LATE_REGISTRATION','MEDICAL','OTHER') NOT NULL,
  reason TEXT NOT NULL,
  status ENUM('PENDING_HOD','PENDING_AR','APPROVED','REJECTED','CANCELLED') NOT NULL DEFAULT 'PENDING_HOD',
  reviewed_by BIGINT UNSIGNED NULL,
  review_comments TEXT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reviewed_at TIMESTAMP NULL,
  CONSTRAINT fk_requests_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_requests_registration FOREIGN KEY (registration_id) REFERENCES registrations(id),
  CONSTRAINT fk_requests_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id),
  INDEX idx_requests_queue (status, student_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  type VARCHAR(40) NOT NULL,
  title VARCHAR(180) NOT NULL,
  message TEXT NOT NULL,
  entity_type VARCHAR(50) NULL,
  entity_id BIGINT UNSIGNED NULL,
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_notifications_user_unread (user_id, read_at, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  actor_user_id BIGINT UNSIGNED NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id VARCHAR(80) NOT NULL,
  old_values JSON NULL,
  new_values JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_user_id) REFERENCES users(id),
  INDEX idx_audit_entity (entity_type, entity_id, created_at),
  INDEX idx_audit_actor (actor_user_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS system_settings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT NOT NULL,
  faculty_id BIGINT UNSIGNED NULL,
  updated_by BIGINT UNSIGNED NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_settings_faculty FOREIGN KEY (faculty_id) REFERENCES faculties(id),
  CONSTRAINT fk_settings_updater FOREIGN KEY (updated_by) REFERENCES users(id),
  CONSTRAINT uq_setting_scope UNIQUE (setting_key, faculty_id)
) ENGINE=InnoDB;

CREATE OR REPLACE VIEW v_student_academic_progress AS
SELECT s.id AS student_id, s.registration_number, u.display_name,
       p.code AS programme_code, p.name AS programme_name,
       p.minimum_credits AS required_credits,
       COALESCE(SUM(CASE WHEN ar.status='COMPLETED' THEN c.credits ELSE 0 END),0) AS completed_credits,
       COALESCE(SUM(CASE WHEN ar.status='MEDICAL' THEN c.credits ELSE 0 END),0) AS medical_credits,
       COALESCE(SUM(CASE WHEN ar.status='DROPPED' THEN c.credits ELSE 0 END),0) AS dropped_credits,
       CASE WHEN COALESCE(SUM(CASE WHEN ar.status='COMPLETED' THEN c.credits ELSE 0 END),0) >= p.minimum_credits
            THEN 'CREDIT_REQUIREMENT_MET' ELSE 'IN_PROGRESS' END AS completion_status
FROM students s
JOIN users u ON u.id=s.user_id
JOIN programmes p ON p.id=s.programme_id
LEFT JOIN academic_results ar ON ar.student_id=s.id
LEFT JOIN courses c ON c.id=ar.course_id
WHERE s.deleted_at IS NULL
GROUP BY s.id,s.registration_number,u.display_name,p.code,p.name,p.minimum_credits;

CREATE OR REPLACE VIEW v_registration_workflow AS
SELECT r.id AS registration_id, s.registration_number, u.display_name AS student_name,
       f.code AS faculty_code, d.code AS department_code, ay.name AS academic_year,
       sem.semester_number, r.total_credits, r.status, r.submitted_at,
       r.hod_decided_at, r.ar_decided_at, r.locked_at, r.verification_token
FROM registrations r
JOIN students s ON s.id=r.student_id
JOIN users u ON u.id=s.user_id
JOIN faculties f ON f.id=s.faculty_id
JOIN departments d ON d.id=s.department_id
JOIN semesters sem ON sem.id=r.semester_id
JOIN academic_years ay ON ay.id=sem.academic_year_id;

CREATE OR REPLACE VIEW v_hod_registration_queue AS
SELECT * FROM v_registration_workflow WHERE status IN ('SUBMITTED','CHANGES_REQUESTED');

CREATE OR REPLACE VIEW v_ar_registration_queue AS
SELECT * FROM v_registration_workflow WHERE status='HOD_APPROVED';

CREATE OR REPLACE VIEW v_student_timetable AS
SELECT r.student_id, r.id AS registration_id, c.code AS course_code, c.title,
       ts.activity_type, ts.group_name, ts.day_of_week, ts.starts_at, ts.ends_at, ts.venue
FROM registrations r
JOIN registration_courses rc ON rc.registration_id=r.id AND rc.status='SELECTED'
JOIN course_offerings co ON co.id=rc.offering_id
JOIN courses c ON c.id=co.course_id
JOIN timetable_slots ts ON ts.offering_id=co.id;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_completed_credits$$
CREATE FUNCTION fn_completed_credits(p_student_id BIGINT UNSIGNED)
RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE v_total INT DEFAULT 0;
  SELECT COALESCE(SUM(c.credits),0) INTO v_total
  FROM academic_results ar JOIN courses c ON c.id=ar.course_id
  WHERE ar.student_id=p_student_id AND ar.status='COMPLETED';
  RETURN v_total;
END$$

DROP FUNCTION IF EXISTS fn_registration_total_credits$$
CREATE FUNCTION fn_registration_total_credits(p_registration_id BIGINT UNSIGNED)
RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE v_total INT DEFAULT 0;
  SELECT COALESCE(SUM(c.credits),0) INTO v_total
  FROM registration_courses rc
  JOIN course_offerings co ON co.id=rc.offering_id
  JOIN courses c ON c.id=co.course_id
  WHERE rc.registration_id=p_registration_id AND rc.status='SELECTED';
  RETURN v_total;
END$$

DROP FUNCTION IF EXISTS fn_user_has_role$$
CREATE FUNCTION fn_user_has_role(p_user_id BIGINT UNSIGNED,p_role VARCHAR(30))
RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
BEGIN
  RETURN EXISTS(SELECT 1 FROM user_roles WHERE user_id=p_user_id AND role_code=p_role);
END$$

DROP FUNCTION IF EXISTS fn_degree_credit_requirement_met$$
CREATE FUNCTION fn_degree_credit_requirement_met(p_student_id BIGINT UNSIGNED)
RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE v_required INT;
  SELECT p.minimum_credits INTO v_required FROM students s JOIN programmes p ON p.id=s.programme_id WHERE s.id=p_student_id;
  RETURN fn_completed_credits(p_student_id) >= COALESCE(v_required,99999);
END$$

DROP PROCEDURE IF EXISTS sp_create_student$$
CREATE PROCEDURE sp_create_student(
  IN p_username VARCHAR(80), IN p_email VARCHAR(190), IN p_password_hash VARCHAR(255),
  IN p_display_name VARCHAR(180), IN p_registration_number VARCHAR(40),
  IN p_faculty_id BIGINT UNSIGNED, IN p_department_id BIGINT UNSIGNED,
  IN p_programme_id BIGINT UNSIGNED, IN p_curriculum_id BIGINT UNSIGNED, IN p_intake_year SMALLINT UNSIGNED
)
BEGIN
  DECLARE v_user_id BIGINT UNSIGNED;
  START TRANSACTION;
  INSERT INTO users(username,email,password_hash,display_name) VALUES(p_username,p_email,p_password_hash,p_display_name);
  SET v_user_id=LAST_INSERT_ID();
  INSERT INTO user_roles(user_id,role_code,faculty_id,department_id) VALUES(v_user_id,'STUDENT',p_faculty_id,p_department_id);
  INSERT INTO students(user_id,registration_number,faculty_id,department_id,programme_id,curriculum_id,intake_year)
  VALUES(v_user_id,p_registration_number,p_faculty_id,p_department_id,p_programme_id,p_curriculum_id,p_intake_year);
  COMMIT;
  SELECT LAST_INSERT_ID() AS student_id,v_user_id AS user_id;
END$$

DROP PROCEDURE IF EXISTS sp_update_student$$
CREATE PROCEDURE sp_update_student(
  IN p_student_id BIGINT UNSIGNED, IN p_display_name VARCHAR(180), IN p_email VARCHAR(190),
  IN p_level TINYINT UNSIGNED, IN p_semester TINYINT UNSIGNED, IN p_academic_status VARCHAR(30), IN p_eligible BOOLEAN
)
BEGIN
  DECLARE v_user_id BIGINT UNSIGNED;
  SELECT user_id INTO v_user_id FROM students WHERE id=p_student_id AND deleted_at IS NULL FOR UPDATE;
  IF v_user_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Student not found'; END IF;
  START TRANSACTION;
  UPDATE users SET display_name=p_display_name,email=p_email WHERE id=v_user_id;
  UPDATE students SET current_level=p_level,current_semester=p_semester,academic_status=p_academic_status,is_registration_eligible=p_eligible WHERE id=p_student_id;
  COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_delete_student$$
CREATE PROCEDURE sp_delete_student(IN p_student_id BIGINT UNSIGNED,IN p_actor_user_id BIGINT UNSIGNED)
BEGIN
  DECLARE v_user_id BIGINT UNSIGNED;
  SELECT user_id INTO v_user_id FROM students WHERE id=p_student_id FOR UPDATE;
  IF v_user_id IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Student not found'; END IF;
  START TRANSACTION;
  UPDATE students SET deleted_at=CURRENT_TIMESTAMP,academic_status='WITHDRAWN',is_registration_eligible=FALSE WHERE id=p_student_id;
  UPDATE users SET status='DISABLED',deleted_at=CURRENT_TIMESTAMP WHERE id=v_user_id;
  INSERT INTO audit_logs(actor_user_id,action,entity_type,entity_id) VALUES(p_actor_user_id,'STUDENT_SOFT_DELETED','student',p_student_id);
  COMMIT;
END$$

DROP PROCEDURE IF EXISTS sp_save_registration_course$$
CREATE PROCEDURE sp_save_registration_course(IN p_registration_id BIGINT UNSIGNED,IN p_offering_id BIGINT UNSIGNED,IN p_type VARCHAR(10))
BEGIN
  DECLARE v_status VARCHAR(30);
  SELECT status INTO v_status FROM registrations WHERE id=p_registration_id FOR UPDATE;
  IF v_status NOT IN ('DRAFT','CHANGES_REQUESTED') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registration is not editable'; END IF;
  INSERT INTO registration_courses(registration_id,offering_id,registration_type,status)
  VALUES(p_registration_id,p_offering_id,p_type,'SELECTED')
  ON DUPLICATE KEY UPDATE registration_type=VALUES(registration_type),status='SELECTED',dropped_at=NULL;
  UPDATE registrations SET total_credits=fn_registration_total_credits(p_registration_id),version=version+1 WHERE id=p_registration_id;
END$$

DROP PROCEDURE IF EXISTS sp_drop_registration_course$$
CREATE PROCEDURE sp_drop_registration_course(IN p_registration_id BIGINT UNSIGNED,IN p_offering_id BIGINT UNSIGNED)
BEGIN
  DECLARE v_status VARCHAR(30);
  SELECT status INTO v_status FROM registrations WHERE id=p_registration_id FOR UPDATE;
  IF v_status NOT IN ('DRAFT','CHANGES_REQUESTED') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registration is not editable'; END IF;
  UPDATE registration_courses SET status='DROPPED',dropped_at=CURRENT_TIMESTAMP WHERE registration_id=p_registration_id AND offering_id=p_offering_id;
  UPDATE registrations SET total_credits=fn_registration_total_credits(p_registration_id),version=version+1 WHERE id=p_registration_id;
END$$

DROP PROCEDURE IF EXISTS sp_submit_registration$$
CREATE PROCEDURE sp_submit_registration(IN p_registration_id BIGINT UNSIGNED,IN p_student_user_id BIGINT UNSIGNED)
BEGIN
  DECLARE v_status VARCHAR(30); DECLARE v_total INT; DECLARE v_min INT; DECLARE v_max INT; DECLARE v_owner BIGINT UNSIGNED;
  SELECT r.status,r.student_id,s.min_semester_credits,s.max_semester_credits,s.user_id
    INTO v_status,@student_id,v_min,v_max,v_owner FROM registrations r JOIN students s ON s.id=r.student_id WHERE r.id=p_registration_id FOR UPDATE;
  SET v_total=fn_registration_total_credits(p_registration_id);
  IF v_owner<>p_student_user_id THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Not the registration owner'; END IF;
  IF v_status NOT IN ('DRAFT','CHANGES_REQUESTED') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid submission state'; END IF;
  IF v_total<v_min OR v_total>v_max THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Credit total outside permitted range'; END IF;
  UPDATE registrations SET status='SUBMITTED',total_credits=v_total,submitted_at=CURRENT_TIMESTAMP,version=version+1 WHERE id=p_registration_id;
  INSERT INTO workflow_actions(registration_id,actor_user_id,actor_role,action,from_status,to_status) VALUES(p_registration_id,p_student_user_id,'STUDENT','SUBMITTED',v_status,'SUBMITTED');
END$$

DROP PROCEDURE IF EXISTS sp_hod_decide_registration$$
CREATE PROCEDURE sp_hod_decide_registration(IN p_registration_id BIGINT UNSIGNED,IN p_actor_user_id BIGINT UNSIGNED,IN p_decision VARCHAR(30),IN p_comments TEXT)
BEGIN
  DECLARE v_status VARCHAR(30); DECLARE v_next VARCHAR(30); DECLARE v_action VARCHAR(30);
  SELECT status INTO v_status FROM registrations WHERE id=p_registration_id FOR UPDATE;
  IF NOT fn_user_has_role(p_actor_user_id,'HOD') AND NOT fn_user_has_role(p_actor_user_id,'SUPER_ADMIN') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='HoD authorization required'; END IF;
  IF v_status<>'SUBMITTED' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registration is not awaiting HoD'; END IF;
  IF p_decision='APPROVE' THEN SET v_next='HOD_APPROVED'; SET v_action='APPROVED';
  ELSEIF p_decision='CHANGES_REQUESTED' THEN SET v_next='CHANGES_REQUESTED'; SET v_action='CHANGES_REQUESTED';
  ELSEIF p_decision='REJECT' THEN SET v_next='REJECTED'; SET v_action='REJECTED';
  ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid HoD decision'; END IF;
  UPDATE registrations SET status=v_next,hod_decided_at=CURRENT_TIMESTAMP,version=version+1 WHERE id=p_registration_id;
  INSERT INTO workflow_actions(registration_id,actor_user_id,actor_role,action,from_status,to_status,comments) VALUES(p_registration_id,p_actor_user_id,'HOD',v_action,v_status,v_next,p_comments);
END$$

DROP PROCEDURE IF EXISTS sp_ar_decide_registration$$
CREATE PROCEDURE sp_ar_decide_registration(IN p_registration_id BIGINT UNSIGNED,IN p_actor_user_id BIGINT UNSIGNED,IN p_decision VARCHAR(30),IN p_comments TEXT)
BEGIN
  DECLARE v_status VARCHAR(30); DECLARE v_next VARCHAR(30); DECLARE v_action VARCHAR(30);
  SELECT status INTO v_status FROM registrations WHERE id=p_registration_id FOR UPDATE;
  IF NOT fn_user_has_role(p_actor_user_id,'ASSISTANT_REGISTRAR') AND NOT fn_user_has_role(p_actor_user_id,'SUPER_ADMIN') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AR authorization required'; END IF;
  IF v_status<>'HOD_APPROVED' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registration is not awaiting AR'; END IF;
  IF p_decision='APPROVE' THEN SET v_next='AR_APPROVED'; SET v_action='APPROVED';
  ELSEIF p_decision='CHANGES_REQUESTED' THEN SET v_next='CHANGES_REQUESTED'; SET v_action='CHANGES_REQUESTED';
  ELSEIF p_decision='REJECT' THEN SET v_next='REJECTED'; SET v_action='REJECTED';
  ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid AR decision'; END IF;
  UPDATE registrations SET status=v_next,ar_decided_at=CURRENT_TIMESTAMP,version=version+1 WHERE id=p_registration_id;
  INSERT INTO workflow_actions(registration_id,actor_user_id,actor_role,action,from_status,to_status,comments) VALUES(p_registration_id,p_actor_user_id,'ASSISTANT_REGISTRAR',v_action,v_status,v_next,p_comments);
END$$

DROP PROCEDURE IF EXISTS sp_final_lock_registration$$
CREATE PROCEDURE sp_final_lock_registration(IN p_registration_id BIGINT UNSIGNED,IN p_actor_user_id BIGINT UNSIGNED,IN p_comments TEXT)
BEGIN
  DECLARE v_status VARCHAR(30); DECLARE v_role VARCHAR(30);
  SELECT status INTO v_status FROM registrations WHERE id=p_registration_id FOR UPDATE;
  IF fn_user_has_role(p_actor_user_id,'SUPER_ADMIN') THEN SET v_role='SUPER_ADMIN';
  ELSEIF fn_user_has_role(p_actor_user_id,'ASSISTANT_REGISTRAR') THEN SET v_role='ASSISTANT_REGISTRAR';
  ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AR or Super Admin authorization required'; END IF;
  IF v_status<>'AR_APPROVED' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Registration must be AR approved before final lock'; END IF;
  UPDATE registrations SET status='LOCKED',locked_at=CURRENT_TIMESTAMP,version=version+1 WHERE id=p_registration_id;
  INSERT INTO workflow_actions(registration_id,actor_user_id,actor_role,action,from_status,to_status,comments) VALUES(p_registration_id,p_actor_user_id,v_role,'LOCKED',v_status,'LOCKED',p_comments);
END$$

DROP PROCEDURE IF EXISTS sp_upsert_academic_result$$
CREATE PROCEDURE sp_upsert_academic_result(
  IN p_student_id BIGINT UNSIGNED,IN p_course_id BIGINT UNSIGNED,IN p_semester_id BIGINT UNSIGNED,
  IN p_status VARCHAR(20),IN p_grade VARCHAR(4),IN p_grade_point DECIMAL(3,2),IN p_actor_user_id BIGINT UNSIGNED
)
BEGIN
  IF NOT fn_user_has_role(p_actor_user_id,'ASSISTANT_REGISTRAR') AND NOT fn_user_has_role(p_actor_user_id,'SUPER_ADMIN') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AR or Super Admin authorization required'; END IF;
  IF p_status NOT IN ('COMPLETED','MEDICAL','DROPPED') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid academic result status'; END IF;
  INSERT INTO academic_results(student_id,course_id,semester_id,status,grade,grade_point,recorded_by)
  VALUES(p_student_id,p_course_id,p_semester_id,p_status,p_grade,p_grade_point,p_actor_user_id)
  ON DUPLICATE KEY UPDATE status=VALUES(status),grade=VALUES(grade),grade_point=VALUES(grade_point),recorded_by=VALUES(recorded_by);
END$$

DROP PROCEDURE IF EXISTS sp_delete_academic_result$$
CREATE PROCEDURE sp_delete_academic_result(IN p_result_id BIGINT UNSIGNED,IN p_actor_user_id BIGINT UNSIGNED)
BEGIN
  IF NOT fn_user_has_role(p_actor_user_id,'SUPER_ADMIN') THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Super Admin authorization required'; END IF;
  DELETE FROM academic_results WHERE id=p_result_id;
  INSERT INTO audit_logs(actor_user_id,action,entity_type,entity_id) VALUES(p_actor_user_id,'ACADEMIC_RESULT_DELETED','academic_result',p_result_id);
END$$

DELIMITER ;
