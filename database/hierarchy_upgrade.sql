USE rusl_course_registration_v2;

ALTER TABLE user_roles
  MODIFY role_code ENUM('STUDENT','HOD','ASSISTANT_REGISTRAR','DEAN','SUPER_ADMIN') NOT NULL;

ALTER TABLE workflow_actions
  MODIFY actor_role ENUM('STUDENT','HOD','ASSISTANT_REGISTRAR','DEAN','SUPER_ADMIN') NOT NULL;

-- Run the idempotent production seed after this migration to populate the
-- official six-faculty, forty-three-department hierarchy and FOT Dean account.
