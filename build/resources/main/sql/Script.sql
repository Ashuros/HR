-- CREATE Backup tables
CREATE TABLE employees_bckp AS SELECT * FROM employees WHERE employee_id < 0;
CREATE TABLE departments_bckp AS SELECT * FROM departments WHERE department_id < 0;
CREATE TABLE countries_bckp AS SELECT * FROM countries WHERE region_id < 0;
CREATE TABLE job_history_bckp AS SELECT * FROM job_history WHERE employee_id < 0;
CREATE TABLE jobs_bckp AS SELECT * FROM jobs WHERE min_salary < 0;
CREATE TABLE locations_bckp AS SELECT * FROM locations WHERE location_id < 0;
CREATE TABLE regions_bckp AS SELECT * FROM regions WHERE region_id < 0;

-- CREATE Sequences
CREATE SEQUENCE countries_seq
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE jobs_seq
 START WITH 1
 INCREMENT BY 1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE regions_seq
 START WITH 5
 INCREMENT BY 1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE locations_seq_new
 START WITH 3300
 INCREMENT BY 10
 NOCACHE
 NOCYCLE;


 COMMIT;