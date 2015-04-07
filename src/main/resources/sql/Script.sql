-- CREATE Backup tables
CREATE TABLE employees_bckp AS SELECT * FROM employees WHERE employee_id < 0;
CREATE TABLE departments_bckp AS SELECT * FROM departments WHERE department_id < 0;
CREATE TABLE countries_bckp AS SELECT * FROM countries WHERE region_id < 0;
CREATE TABLE job_history_bckp AS SELECT * FROM job_history WHERE employee_id < 0;
CREATE TABLE jobs_bckp AS SELECT * FROM jobs WHERE min_salary < 0;
CREATE TABLE locations_bckp AS SELECT * FROM locations WHERE location_id < 0;
CREATE TABLE regions_bckp AS SELECT * FROM regions WHERE region_id < 0;

-- CREATE AUXILIARY FUNCTIONS
CREATE OR REPLACE FUNCTION get_all_tables
   RETURN VARCHAR2 IS all_tables VARCHAR2(1024) := '';
BEGIN
   FOR rec IN (SELECT table_name FROM user_tables WHERE table_name NOT LIKE '%_BCKP')
   LOOP
      all_tables := all_tables || rec.table_name || ',';
   END LOOP;
   DBMS_OUTPUT.PUT_LINE(all_tables);
   RETURN all_tables;
END;

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