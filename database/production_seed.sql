USE rusl_course_registration_v2;

INSERT IGNORE INTO faculties(id,code,name) VALUES
(1,'FOT','Faculty of Technology'),
(2,'FAS','Faculty of Applied Sciences'),
(3,'FMS','Faculty of Management Studies'),
(4,'FOA','Faculty of Agriculture'),
(5,'FMAS','Faculty of Medicine and Allied Sciences'),
(6,'FSSH','Faculty of Social Sciences and Humanities');

INSERT IGNORE INTO departments(id,faculty_id,code,name) VALUES
(1,1,'ICT','Department of Information and Communication Technology'),
(2,1,'BPT','Department of Bioprocess Technology'),
(3,1,'ET','Department of Engineering Technology'),
(4,1,'FT','Department of Food Technology'),
(5,1,'MT','Department of Materials Technology'),
(6,2,'CS','Department of Computing'),
(7,3,'ACC','Department of Accountancy and Finance'),
(8,2,'BIO','Department of Biological Sciences'),
(9,2,'CHE','Department of Chemical Sciences'),
(10,2,'HPR','Department of Health Promotion'),
(11,2,'PHY','Department of Physical Sciences'),
(12,3,'BMG','Department of Business Management'),
(13,3,'THM','Department of Tourism and Hospitality Management'),
(14,3,'MKT','Department of Marketing Management'),
(15,3,'HRM','Department of Human Resource Management'),
(16,3,'ISM','Department of Information Systems'),
(17,4,'AES','Department of Agricultural Engineering and Soil Science'),
(18,4,'AGS','Department of Agricultural Systems'),
(19,4,'AFS','Department of Animal and Food Sciences'),
(20,4,'PLS','Department of Plant Sciences'),
(21,5,'ANA','Department of Anatomy'),
(22,5,'BCH','Department of Biochemistry'),
(23,5,'PHS','Department of Physiology'),
(24,5,'MIC','Department of Microbiology'),
(25,5,'PAR','Department of Parasitology'),
(26,5,'PHA','Department of Pharmacology'),
(27,5,'PAT','Department of Pathology'),
(28,5,'COM','Department of Community Medicine'),
(29,5,'FOR','Department of Forensic Medicine'),
(30,5,'FAM','Department of Family Medicine'),
(31,5,'MED','Department of Medicine'),
(32,5,'SUR','Department of Surgery'),
(33,5,'PAE','Department of Paediatrics'),
(34,5,'OBG','Department of Gynaecology and Obstetrics'),
(35,5,'PSY','Department of Psychiatry'),
(36,6,'AHM','Department of Archaeology and Heritage Management'),
(37,6,'ELT','Department of English Language Teaching'),
(38,6,'SOC','Department of Social Sciences'),
(39,6,'LAN','Department of Languages'),
(40,6,'HUM','Department of Humanities'),
(41,6,'ENM','Department of Environmental Management'),
(42,6,'ECO','Department of Economics'),
(43,6,'IT','Department of Information Technology');

INSERT IGNORE INTO programmes(id,department_id,code,name,degree_type,duration_years,minimum_credits) VALUES
(1,1,'BICT-HONS','Bachelor of Information and Communication Technology Honours','Bachelor of Honours',4,120);

INSERT IGNORE INTO curricula(id,programme_id,version,effective_from_year,minimum_credits,status) VALUES
(1,1,'BICT-2021',2021,120,'ACTIVE');

-- Development password for all demo accounts: RuslPass#2026
INSERT IGNORE INTO users(id,username,email,password_hash,display_name) VALUES
(1,'student_nafis','student.nafis@rjt.ac.lk','$2y$10$kKgnBeKVkAe5TvLptKAD.uCtyA4DXy/8Pr84dnXI.DNMP6i.R6I5a','M. N. Mohamed Nafis'),
(2,'hod_ict','lahiruj@tec.rjt.ac.lk','$2y$10$kKgnBeKVkAe5TvLptKAD.uCtyA4DXy/8Pr84dnXI.DNMP6i.R6I5a','Dr. Lahiru Jayasuriya'),
(3,'ar_fot','ar@tec.rjt.ac.lk','$2y$10$kKgnBeKVkAe5TvLptKAD.uCtyA4DXy/8Pr84dnXI.DNMP6i.R6I5a','Ms. K. H. Gaurika Kahawala'),
(4,'sysadmin','director@cc.rjt.ac.lk','$2y$10$kKgnBeKVkAe5TvLptKAD.uCtyA4DXy/8Pr84dnXI.DNMP6i.R6I5a','Mr. P. S. Palliyaguruge'),
(5,'dean_fot','dean@tec.rjt.ac.lk','$2y$10$kKgnBeKVkAe5TvLptKAD.uCtyA4DXy/8Pr84dnXI.DNMP6i.R6I5a','Prof. T. C. Bamunuarachchige');

INSERT IGNORE INTO user_roles(id,user_id,role_code,faculty_id,department_id) VALUES
(1,1,'STUDENT',1,1),(2,2,'HOD',1,1),(3,3,'ASSISTANT_REGISTRAR',1,NULL),(4,4,'SUPER_ADMIN',NULL,NULL),(5,5,'DEAN',1,NULL);

INSERT IGNORE INTO students(id,user_id,registration_number,faculty_id,department_id,programme_id,curriculum_id,intake_year,current_level,current_semester) VALUES
(1,1,'ICT/2021/045',1,1,1,1,2021,3,2);

INSERT IGNORE INTO staff(id,user_id,employee_number,faculty_id,department_id,designation) VALUES
(1,2,'RUSL/FOT/ICT/001',1,1,'Head of Department'),
(2,3,'RUSL/FOT/AR/001',1,NULL,'Assistant Registrar'),
(3,4,'RUSL/IT/001',NULL,NULL,'Director, CITS / System Administrator'),
(4,5,'RUSL/FOT/DEAN/001',1,NULL,'Dean');

INSERT IGNORE INTO academic_years(id,name,starts_on,ends_on,status) VALUES
(1,'2025/2026','2025-09-01','2026-12-31','ACTIVE');
INSERT IGNORE INTO semesters(id,academic_year_id,semester_number,starts_on,ends_on,status) VALUES
(1,1,2,'2026-10-01','2027-03-31','OPEN');
INSERT IGNORE INTO registration_periods(id,semester_id,faculty_id,opens_at,closes_at,late_closes_at,is_enabled,created_by) VALUES
(1,1,1,'2026-10-01 00:00:00','2026-10-31 23:59:59','2026-11-07 23:59:59',TRUE,4);

INSERT IGNORE INTO courses(id,department_id,code,title,description,credits,level) VALUES
(1,1,'ICT 1201','Programming Fundamentals','Introduction to programming, logic, arrays and algorithms.',2,1),
(2,1,'ICT 1202','Database Management Systems','Relational algebra, SQL and normalization.',3,1),
(3,1,'ICT 2203','Object Oriented Programming','Object-oriented programming and design.',3,2),
(4,1,'ICT 3201','Software Project Management','BICT Year 3 Semester 1 compulsory course.',2,3),
(5,1,'ICT 3203','Scientific Computer Applications','BICT Year 3 Semester 1 compulsory course.',2,3),
(6,1,'ICT 3206','Skill Development Project III','BICT Year 3 Semester 1 compulsory course.',2,3),
(7,1,'ICT 3307','Computational Statistics','BICT Year 3 Semester 1 optional course.',3,3),
(8,1,'ICT 3208','Design and Analysis of Algorithms','BICT Year 3 Semester 1 compulsory course.',2,3),
(9,1,'ICT 3312','Software Verification and Validation','BICT Year 3 Semester 1 compulsory course.',3,3),
(10,1,'CML 3101','Legal and Patent Aspects','BICT Year 3 Semester 1 compulsory complementary course.',1,3),
(11,1,'ICT 3315','Internet of Things','BICT Year 3 Semester 1 optional course.',3,3),
(12,1,'ICT 3217','Advanced Computer Networks','BICT Year 3 Semester 1 optional course.',2,3),
(13,1,'ICT 3218','Basics of Virtual Reality','BICT Year 3 Semester 1 optional course.',2,3);

INSERT IGNORE INTO curriculum_courses(curriculum_id,course_id,level,semester_number,requirement_type) VALUES
(1,1,1,1,'COMPULSORY'),(1,2,1,2,'COMPULSORY'),(1,3,2,1,'COMPULSORY'),
(1,4,3,1,'COMPULSORY'),(1,5,3,1,'COMPULSORY'),(1,6,3,1,'COMPULSORY'),
(1,7,3,1,'OPTIONAL'),(1,8,3,1,'COMPULSORY'),(1,9,3,1,'COMPULSORY'),
(1,10,3,1,'COMPULSORY'),(1,11,3,1,'OPTIONAL'),(1,12,3,1,'OPTIONAL'),(1,13,3,1,'OPTIONAL');

INSERT IGNORE INTO course_prerequisites(course_id,prerequisite_course_id,minimum_grade) VALUES
(2,1,'C'),(3,1,'C'),(4,3,'C');

INSERT IGNORE INTO course_offerings(id,course_id,semester_id,capacity,registered_count,status) VALUES
(1,4,1,60,45,'OPEN'),(2,5,1,40,38,'OPEN'),(3,6,1,50,48,'OPEN'),
(4,7,1,35,28,'OPEN'),(5,8,1,45,42,'OPEN'),(6,9,1,40,32,'OPEN'),
(7,10,1,80,58,'OPEN'),(8,11,1,35,25,'OPEN'),(9,12,1,40,30,'OPEN'),(10,13,1,30,22,'OPEN');

INSERT IGNORE INTO timetable_slots(offering_id,activity_type,group_name,day_of_week,starts_at,ends_at,venue) VALUES
(1,'LECTURE','All','MONDAY','08:30:00','10:30:00','FOT Hall 01'),
(2,'LECTURE','All','TUESDAY','08:30:00','10:30:00','FOT Hall 02'),
(3,'PRACTICAL','Group A','WEDNESDAY','10:30:00','12:30:00','ICT Laboratory 01'),
(5,'LECTURE','All','THURSDAY','08:30:00','10:30:00','FOT Hall 01'),
(6,'LECTURE','All','FRIDAY','10:30:00','12:30:00','FOT Hall 02');

INSERT IGNORE INTO registrations(id,student_id,semester_id,status,total_credits,verification_token) VALUES
(1,1,1,'DRAFT',0,'550e8400-e29b-41d4-a716-446655440000');

-- Historical results: only COMPLETED contributes to the degree-credit total.
INSERT IGNORE INTO academic_results(id,student_id,course_id,semester_id,status,grade,grade_point,recorded_by) VALUES
(1,1,1,1,'COMPLETED','B+',3.30,3),
(2,1,2,1,'COMPLETED','A-',3.70,3),
(3,1,3,1,'COMPLETED','B',3.00,3);

INSERT IGNORE INTO system_settings(setting_key,setting_value,updated_by) VALUES
('application_name','RUSL Course Registration System',4),
('workflow','STUDENT>HOD>ASSISTANT_REGISTRAR>FINAL_LOCK',4),
('waiting_list_enabled','false',4);
