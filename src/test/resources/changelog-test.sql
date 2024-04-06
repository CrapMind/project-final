CREATE SEQUENCE IF NOT EXISTS mail_case_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS user_belong_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS activity_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS task_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS sprint_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS project_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS reference_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS attachment_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS users_id_seq START WITH 1 INCREMENT BY 1;

DROP TABLE IF EXISTS USER_ROLE CASCADE;
DROP TABLE IF EXISTS CONTACT CASCADE;
DROP TABLE IF EXISTS MAIL_CASE CASCADE;
DROP TABLE IF EXISTS PROFILE CASCADE;
DROP TABLE IF EXISTS TASK_TAG CASCADE;
DROP TABLE IF EXISTS USER_BELONG CASCADE;
DROP TABLE IF EXISTS ACTIVITY CASCADE;
DROP TABLE IF EXISTS TASK CASCADE;
DROP TABLE IF EXISTS SPRINT CASCADE;
DROP TABLE IF EXISTS PROJECT CASCADE;
DROP TABLE IF EXISTS REFERENCE CASCADE;
DROP TABLE IF EXISTS ATTACHMENT CASCADE;
DROP TABLE IF EXISTS USERS CASCADE;

CREATE TABLE PROJECT (
      ID BIGINT DEFAULT NEXTVAL('project_id_seq') PRIMARY KEY,
      CODE VARCHAR(32) NOT NULL UNIQUE,
      TITLE VARCHAR(1024) NOT NULL,
      DESCRIPTION VARCHAR(4096) NOT NULL,
      TYPE_CODE VARCHAR(32) NOT NULL,
      STARTPOINT TIMESTAMP,
      ENDPOINT TIMESTAMP,
      PARENT_ID BIGINT,
      FOREIGN KEY (PARENT_ID) REFERENCES PROJECT(ID) ON DELETE CASCADE
);

CREATE TABLE MAIL_CASE (
      ID BIGINT DEFAULT NEXTVAL('mail_case_id_seq') PRIMARY KEY,
      EMAIL VARCHAR(255) NOT NULL,
      NAME VARCHAR(255) NOT NULL,
      DATE_TIME TIMESTAMP NOT NULL,
      RESULT VARCHAR(255) NOT NULL,
      TEMPLATE VARCHAR(255) NOT NULL
);

CREATE TABLE SPRINT (
      ID BIGINT DEFAULT NEXTVAL('sprint_id_seq') PRIMARY KEY,
      STATUS_CODE VARCHAR(32) NOT NULL,
      STARTPOINT TIMESTAMP,
      ENDPOINT TIMESTAMP,
      TITLE VARCHAR(1024) NOT NULL,
      PROJECT_ID BIGINT NOT NULL,
      FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT(ID) ON DELETE CASCADE
);

CREATE TABLE REFERENCE (
      ID BIGINT DEFAULT NEXTVAL('reference_id_seq') PRIMARY KEY,
      CODE VARCHAR(32) NOT NULL,
      REF_TYPE SMALLINT NOT NULL,
      ENDPOINT TIMESTAMP,
      STARTPOINT TIMESTAMP,
      TITLE VARCHAR(1024) NOT NULL,
      AUX VARCHAR,
      UNIQUE (REF_TYPE, CODE)
);

CREATE TABLE USERS (
      ID BIGINT DEFAULT NEXTVAL('users_id_seq') PRIMARY KEY,
      DISPLAY_NAME VARCHAR(32) NOT NULL UNIQUE,
      EMAIL VARCHAR(128) NOT NULL UNIQUE,
      FIRST_NAME VARCHAR(32) NOT NULL,
      LAST_NAME VARCHAR(32),
      PASSWORD VARCHAR(128) NOT NULL,
      ENDPOINT TIMESTAMP,
      STARTPOINT TIMESTAMP
);

CREATE TABLE PROFILE (
      ID BIGINT PRIMARY KEY,
      LAST_LOGIN TIMESTAMP,
      LAST_FAILED_LOGIN TIMESTAMP,
      MAIL_NOTIFICATIONS BIGINT,
      FOREIGN KEY (ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

CREATE TABLE CONTACT (
     ID BIGINT NOT NULL,
     CODE VARCHAR(32) NOT NULL,
     CONTACT_VALUE VARCHAR(256) NOT NULL, ----rename "value" to "contact_value" due to h2 syntax
     PRIMARY KEY (ID, CODE),
     FOREIGN KEY (ID) REFERENCES PROFILE(ID) ON DELETE CASCADE
);

CREATE TABLE TASK (
     ID BIGINT DEFAULT NEXTVAL('task_id_seq') PRIMARY KEY,
     TITLE VARCHAR(1024) NOT NULL,
     DESCRIPTION VARCHAR(4096) NOT NULL,
     TYPE_CODE VARCHAR(32) NOT NULL,
     STATUS_CODE VARCHAR(32) NOT NULL,
     PRIORITY_CODE VARCHAR(32) NOT NULL,
     ESTIMATE INTEGER,
     UPDATED TIMESTAMP,
     PROJECT_ID BIGINT NOT NULL,
     SPRINT_ID BIGINT,
     PARENT_ID BIGINT,
     STARTPOINT TIMESTAMP,
     ENDPOINT TIMESTAMP,
     FOREIGN KEY (SPRINT_ID) REFERENCES SPRINT(ID) ON DELETE SET NULL,
     FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT(ID) ON DELETE CASCADE,
     FOREIGN KEY (PARENT_ID) REFERENCES TASK(ID) ON DELETE CASCADE
);

CREATE TABLE ACTIVITY (
     ID BIGINT DEFAULT NEXTVAL('activity_id_seq') PRIMARY KEY,
     AUTHOR_ID BIGINT NOT NULL,
     TASK_ID BIGINT NOT NULL,
     UPDATED TIMESTAMP,
     COMMENT VARCHAR(4096),
     TITLE VARCHAR(1024),
     DESCRIPTION VARCHAR(4096),
     ESTIMATE INTEGER,
     TYPE_CODE VARCHAR(32),
     STATUS_CODE VARCHAR(32),
     PRIORITY_CODE VARCHAR(32),
     FOREIGN KEY (AUTHOR_ID) REFERENCES USERS(ID) ON DELETE CASCADE,
     FOREIGN KEY (TASK_ID) REFERENCES TASK(ID) ON DELETE CASCADE
);

CREATE TABLE TASK_TAG (
     TASK_ID BIGINT NOT NULL,
     TAG VARCHAR(32) NOT NULL,
     PRIMARY KEY (TASK_ID, TAG),
     FOREIGN KEY (TASK_ID) REFERENCES TASK(ID) ON DELETE CASCADE
);

CREATE TABLE USER_BELONG (
     ID BIGINT DEFAULT NEXTVAL('user_belong_id_seq') PRIMARY KEY,
     OBJECT_ID BIGINT NOT NULL,
     OBJECT_TYPE SMALLINT NOT NULL,
     USER_ID BIGINT NOT NULL,
     USER_TYPE_CODE VARCHAR(32) NOT NULL,
     STARTPOINT TIMESTAMP,
     ENDPOINT TIMESTAMP,
     FOREIGN KEY (USER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

CREATE TABLE ATTACHMENT (
     ID BIGINT DEFAULT NEXTVAL('attachment_id_seq') PRIMARY KEY,
     NAME VARCHAR(128) NOT NULL,
     FILE_LINK VARCHAR(2048) NOT NULL,
     OBJECT_ID BIGINT NOT NULL,
     OBJECT_TYPE SMALLINT NOT NULL,
     USER_ID BIGINT NOT NULL,
     DATE_TIME TIMESTAMP,
     FOREIGN KEY (USER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

CREATE TABLE USER_ROLE (
     USER_ID BIGINT NOT NULL,
     ROLE SMALLINT NOT NULL,
     PRIMARY KEY (USER_ID, ROLE),
     FOREIGN KEY (USER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

--changeset kmpk:populate_data
--============ References =================
insert into REFERENCE (CODE, TITLE, REF_TYPE)
-- TASK
values ('task', 'Task', 2),
       ('story', 'Story', 2),
       ('bug', 'Bug', 2),
       ('epic', 'Epic', 2),
-- SPRINT_STATUS
       ('planning', 'Planning', 4),
       ('active', 'Active', 4),
       ('finished', 'Finished', 4),
-- USER_TYPE
       ('author', 'Author', 5),
       ('developer', 'Developer', 5),
       ('reviewer', 'Reviewer', 5),
       ('tester', 'Tester', 5),
-- PROJECT
       ('scrum', 'Scrum', 1),
       ('task_tracker', 'Task tracker', 1),
-- CONTACT
       ('skype', 'Skype', 0),
       ('tg', 'Telegram', 0),
       ('mobile', 'Mobile', 0),
       ('phone', 'Phone', 0),
       ('website', 'Website', 0),
       ('linkedin', 'LinkedIn', 0),
       ('github', 'GitHub', 0),
-- PRIORITY
       ('critical', 'Critical', 7),
       ('high', 'High', 7),
       ('normal', 'Normal', 7),
       ('low', 'Low', 7),
       ('neutral', 'Neutral', 7);

insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
-- MAIL_NOTIFICATION
values ('assigned', 'Assigned', 6, '1'),
       ('three_days_before_deadline', 'Three days before deadline', 6, '2'),
       ('two_days_before_deadline', 'Two days before deadline', 6, '4'),
       ('one_day_before_deadline', 'One day before deadline', 6, '8'),
       ('deadline', 'Deadline', 6, '16'),
       ('overdue', 'Overdue', 6, '32'),
-- TASK_STATUS
       ('todo', 'ToDo', 3, 'in_progress,canceled'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled'),
       ('ready_for_review', 'Ready for review', 3, 'review,canceled'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled'),
       ('ready_for_test', 'Ready for test', 3, 'test,canceled'),
       ('test', 'Test', 3, 'done,in_progress,canceled'),
       ('done', 'Done', 3, 'canceled'),
       ('canceled', 'Canceled', 3, null);

--changeset gkislin:change_backtracking_tables

ALTER TABLE SPRINT ALTER COLUMN TITLE RENAME TO CODE;
ALTER TABLE SPRINT ALTER COLUMN CODE SET DATA TYPE VARCHAR(32);
ALTER TABLE SPRINT ALTER COLUMN CODE SET NOT NULL;
CREATE UNIQUE INDEX UK_SPRINT_PROJECT_CODE ON SPRINT (PROJECT_ID, CODE);

ALTER TABLE TASK
    DROP COLUMN DESCRIPTION;
ALTER TABLE TASK
    DROP COLUMN PRIORITY_CODE;
ALTER TABLE TASK
    DROP COLUMN ESTIMATE;
ALTER TABLE TASK
    DROP COLUMN UPDATED;

--changeset ishlyakhtenkov:change_task_status_reference

delete
from REFERENCE
where REF_TYPE = 3;
insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
values ('todo', 'ToDo', 3, 'in_progress,canceled'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled'),
       ('ready_for_review', 'Ready for review', 3, 'in_progress,review,canceled'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled'),
       ('ready_for_test', 'Ready for test', 3, 'review,test,canceled'),
       ('test', 'Test', 3, 'done,in_progress,canceled'),
       ('done', 'Done', 3, 'canceled'),
       ('canceled', 'Canceled', 3, null);

--changeset gkislin:users_add_on_delete_cascade

alter table ACTIVITY drop constraint IF EXISTS FK_ACTIVITY_USERS;
alter table ACTIVITY add constraint FK_ACTIVITY_USERS foreign key (AUTHOR_ID) references USERS (ID) on delete cascade;

alter table USER_BELONG drop constraint IF EXISTS FK_USER_BELONG;
alter table USER_BELONG add constraint FK_USER_BELONG foreign key (USER_ID) references USERS (ID) on delete cascade;

alter table ATTACHMENT drop constraint IF EXISTS FK_ATTACHMENT;
alter table ATTACHMENT add constraint FK_ATTACHMENT foreign key (USER_ID) references USERS (ID) on delete cascade;

--changeset valeriyemelyanov:change_user_type_reference

delete
from REFERENCE
where REF_TYPE = 5;
insert into REFERENCE (CODE, TITLE, REF_TYPE)
-- USER_TYPE
values ('project_author', 'Author', 5),
       ('project_manager', 'Manager', 5),
       ('sprint_author', 'Author', 5),
       ('sprint_manager', 'Manager', 5),
       ('task_author', 'Author', 5),
       ('task_developer', 'Developer', 5),
       ('task_reviewer', 'Reviewer', 5),
       ('task_tester', 'Tester', 5);

--changeset apolik:refactor_reference_aux

-- TASK_TYPE
delete
from REFERENCE
where REF_TYPE = 3;
insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
values ('todo', 'ToDo', 3, 'in_progress,canceled|'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled|task_developer'),
       ('ready_for_review', 'Ready for review', 3, 'in_progress,review,canceled|'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled|task_reviewer'),
       ('ready_for_test', 'Ready for test', 3, 'review,test,canceled|'),
       ('test', 'Test', 3, 'done,in_progress,canceled|task_tester'),
       ('done', 'Done', 3, 'canceled|'),
       ('canceled', 'Canceled', 3, null);

