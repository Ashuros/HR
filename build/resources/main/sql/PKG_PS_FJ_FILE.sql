CREATE OR REPLACE PACKAGE PKG_PS_FJ_FILE
AS
  PROCEDURE save_data_to_file(in_tableName IN VARCHAR2, in_separator IN VARCHAR2);
  FUNCTION load_data_from_file(in_fileDir VARCHAR2, in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  PROCEDURE load_data(in_tableName IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  
  FUNCTION is_user_directory(file_dir VARCHAR2) RETURN BOOLEAN;
  FUNCTION toNumber(probablyNumber VARCHAR2) RETURN NUMBER;
  FUNCTION toDate(probablyDate VARCHAR2) RETURN DATE;
  FUNCTION toVarchar(probablyVarchar VARCHAR2) RETURN VARCHAR2;
END PKG_PS_FJ_FILE;
/

CREATE OR REPLACE PACKAGE BODY PKG_PS_FJ_FILE
AS
  -- >>>>>>>>> PRIVATE SECTION <<<<<<<<< --
  -- SAVE TO FILE
  PROCEDURE save_employees(in_sep IN VARCHAR2);
  PROCEDURE save_departments(in_sep IN VARCHAR2);
  PROCEDURE save_countries(in_sep IN VARCHAR2);
  PROCEDURE save_job_history(in_sep IN VARCHAR2);
  PROCEDURE save_jobs(in_sep IN VARCHAR2);
  PROCEDURE save_locations(in_sep IN VARCHAR2);
  PROCEDURE save_regions(in_sep IN VARCHAR2);

  -- LOAD FROM FILE
  FUNCTION load_employees_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  FUNCTION load_countries_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  FUNCTION load_departments_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  FUNCTION load_job_history_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  FUNCTION load_jobs_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  FUNCTION load_locations_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;
  FUNCTION load_regions_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER;

  -- COPY FROM BCKP TO ORIGINAL ONE
  PROCEDURE copy_to_employees(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  PROCEDURE copy_to_departments(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  PROCEDURE copy_to_countries(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  PROCEDURE copy_to_job_history(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  PROCEDURE copy_to_jobs(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  PROCEDURE copy_to_locations(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  PROCEDURE copy_to_regions(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER);
  -- <<<<<<<<< PRIVATE SECTION >>>>>>>>> --

  -- >>>>>>>>> PUBLIC DEFINITION - SAVE DATA TO FILES <<<<<<<<< --
  PROCEDURE save_data_to_file(in_tableName IN VARCHAR2, in_separator IN VARCHAR2)
  IS
  BEGIN
      CASE LOWER(in_tableName)
        WHEN 'employees'   THEN save_employees(in_separator);
        WHEN 'departments' THEN save_departments(in_separator);
        WHEN 'countries'   THEN save_countries(in_separator);
        WHEN 'job_history' THEN save_job_history(in_separator);
        WHEN 'jobs'        THEN save_jobs(in_separator);
        WHEN 'locations'   THEN save_locations(in_separator);
        WHEN 'regions'     THEN save_regions(in_separator);
      END CASE;
  END;
  -- <<<<<<<<< PUBLIC DEFINITION - SAVE DATA TO FILES >>>>>>>>> --


  -- >>>>>>>>> PRIVATE DEFINITIONS - SAVE TABLES TO FILES <<<<<<<<< --
  -- SAVE EMPLOYEES TO FILE
  PROCEDURE save_employees(in_sep IN VARCHAR2)
  IS
    f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'EMPLOYEES.csv', 'w');
    v_new_id NUMBER(8);
  BEGIN
    FOR cur IN (SELECT * FROM employees)
    LOOP
        v_new_id := employees_seq.NEXTVAL;
        UTL_FILE.PUT_LINE(f_handle,  v_new_id || in_sep || cur.first_name || in_sep || cur.last_name || in_sep ||
                                    cur.email || v_new_id || in_sep || cur.phone_number || in_sep || cur.hire_date || in_sep ||
                                    cur.job_id || in_sep || cur.salary || in_sep || cur.commission_pct || in_sep ||
                                    cur.manager_id || in_sep || cur.department_id);
    END LOOP;
    UTL_FILE.FCLOSE(f_handle);
  EXCEPTION
    WHEN OTHERS THEN UTL_FILE.FCLOSE(f_handle);
  END;

  -- SAVE DEPARTMENTS TO FILE
  PROCEDURE save_departments(in_sep IN VARCHAR2)
  IS
    f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'DEPARTMENTS.csv', 'w');
  BEGIN
    FOR cur IN (SELECT * FROM departments)
    LOOP
        UTL_FILE.PUT_LINE(f_handle, departments_seq.NEXTVAL || in_sep || cur.department_name || in_sep ||
                                    cur.manager_id || in_sep || cur.location_id);
    END LOOP;
    UTL_FILE.FCLOSE(f_handle);
  EXCEPTION
    WHEN OTHERS THEN UTL_FILE.FCLOSE(f_handle);
  END;

  -- SAVE COUNTRIES TO FILE
  PROCEDURE save_countries(in_sep IN VARCHAR2)
  IS
    f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'COUNTRIES.csv', 'w');
  BEGIN

    FOR cur IN (SELECT * FROM countries)
    LOOP
      UTL_FILE.PUT_LINE(f_handle, countries_seq.nextval || in_sep || cur.country_name || in_sep || cur.region_id);
    END LOOP;

    UTL_FILE.FCLOSE(f_handle);
    EXCEPTION
      WHEN OTHERS THEN UTL_FILE.FCLOSE(f_handle);
  END;


  -- SAVE JOB HISTORY TO FILE
  PROCEDURE save_job_history(in_sep IN VARCHAR2)
    IS
      f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'JOB_HISTORY.csv', 'w');
  BEGIN

      FOR cur IN (SELECT * FROM job_history)
      LOOP
        UTL_FILE.PUT_LINE(f_handle, cur.EMPLOYEE_ID || in_sep || ADD_MONTHS(cur.start_date, -1) || in_sep || cur.end_date || in_sep || cur.job_id || in_sep || cur.department_id);
      END LOOP;

      UTL_FILE.FCLOSE(f_handle);
      EXCEPTION
        WHEN OTHERS THEN UTL_FILE.FCLOSE(f_handle);
  END;

  -- SAVE JOBS TO FILE
 PROCEDURE save_jobs(in_sep IN VARCHAR2)
    IS
      f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'JOBS.csv', 'w');
  BEGIN
      FOR cur IN (SELECT * FROM jobs)
      LOOP
        UTL_FILE.PUT_LINE(f_handle, jobs_seq.nextval || in_sep || cur.job_title || in_sep || cur.min_salary || in_sep || cur.max_salary);
      END LOOP;

      UTL_FILE.FCLOSE(f_handle);
      EXCEPTION
        WHEN OTHERS THEN UTL_FILE.FCLOSE(f_handle);
  END;

  -- SAVE LOCATIONS TO FILE
  PROCEDURE save_locations(in_sep IN VARCHAR2)
  IS
    f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'LOCATIONS.csv', 'w');
  BEGIN
    FOR cur IN (SELECT * FROM locations)
    LOOP
      UTL_FILE.PUT_LINE(f_handle, locations_seq.nextval || in_sep || cur.street_address || in_sep || cur.postal_code || in_sep || cur.city || in_sep || cur.state_province || in_sep || cur.country_id);
    END LOOP;
    UTL_FILE.FCLOSE(f_handle);
    EXCEPTION
      WHEN OTHERS THEN
        UTL_FILE.FCLOSE(f_handle);
  END;

  -- SAVE REGIONS TO FILE
  PROCEDURE save_regions(in_sep IN VARCHAR2)
  IS
    f_handle UTL_FILE.FILE_TYPE := UTL_FILE.FOPEN('OUTPUT_DIR', 'REGIONS.csv', 'w');
  BEGIN
    FOR cur IN (SELECT * FROM regions)
    LOOP
      UTL_FILE.PUT_LINE(f_handle, regions_seq.nextval || in_sep || cur.region_name);
    END LOOP;
    UTL_FILE.FCLOSE(f_handle);
    EXCEPTION
      WHEN OTHERS THEN
        UTL_FILE.FCLOSE(f_handle);
  END;
  -- <<<<<<<<< PRIVATE DEFINITIONS - SAVE TABLES TO FILES >>>>>>>>> --


  -- >>>>>>>>> PUBLIC DEFINITION - LOAD DATA FROM FILES <<<<<<<<< --
  -- LOAD DATA FROM FILES
  FUNCTION load_data_from_file(in_fileDir VARCHAR2, in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
  BEGIN
    IF NOT is_user_directory(in_fileDir) THEN
      RETURN -1;
    END IF;

    CASE LOWER(in_fileName)
      WHEN 'employees.csv'   THEN RETURN load_employees_from_file(in_fileName, in_separator);
      WHEN 'countries.csv'   THEN RETURN load_countries_from_file(in_fileName, in_separator);
      WHEN 'departments.csv' THEN RETURN load_departments_from_file(in_fileName, in_separator);
      WHEN 'job_history.csv' THEN RETURN load_job_history_from_file(in_fileName, in_separator);
      WHEN 'jobs.csv'        THEN RETURN load_jobs_from_file(in_fileName, in_separator);
      WHEN 'locations.csv'   THEN RETURN load_locations_from_file(in_fileName, in_separator);
      WHEN 'regions.csv'     THEN RETURN load_regions_from_file(in_fileName, in_separator);
      ELSE RETURN -2;
    END CASE;
  END;
  -- <<<<<<<<< PUBLIC DEFINITION - LOAD DATA FROM FILES >>>>>>>>> --


  -- >>>>>>>>> PRIVATE DEFINITIONS - LOAD TABLES FROM FILES TO BACKUP TABLES <<<<<<<<< --
  -- LOADS EMPLOYESS FROM FILE TO EMPLOYEES_BCKP
  FUNCTION load_employees_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line  VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO employees_bckp VALUES ( v_array(1), v_array(2), v_array(3), v_array(4), v_array(5), v_array(6), v_array(7), v_array(8), v_array(9), v_array(10), v_array(11) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
            END;
  END;

  -- LOADS COUNTRIES FROM FILE TO COUNTRIES_BCKP
  FUNCTION load_countries_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO countries_bckp VALUES ( v_array(1), v_array(2), v_array(3) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
            END;
  END;

  -- LOADS DEPARTMENTS FROM FILE TO DEPARTMENTS_BCKP
  FUNCTION load_departments_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO departments_bckp VALUES ( v_array(1), v_array(2), v_array(3), v_array(4) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
            END;
  END;

  -- LOADS JOB_HISTORY FROM FILE TO DEPARTMENTS_BCKP
  FUNCTION load_job_history_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO job_history_bckp VALUES ( v_array(1), v_array(2), v_array(3), v_array(4), v_array(5) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
            END;
  END;

  -- LOADS JOBS FROM FILE TO JOBS_BCKP
  FUNCTION load_jobs_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO jobs_bckp VALUES ( v_array(1), v_array(2), v_array(3), v_array(4) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
                RETURN v_count;
            END;
  END;

  -- LOADS LOCATIONS FROM FILE TO LOCATIONS_BCKP
  FUNCTION load_locations_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO locations_bckp VALUES ( v_array(1), v_array(2), v_array(3), v_array(4), v_array(5), v_array(6) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
            END;
  END;

  -- LOADS REGIONS FROM FILE TO REGIONS_BCKP
  FUNCTION load_regions_from_file(in_fileName VARCHAR2, in_separator VARCHAR2) RETURN NUMBER
  IS
      v_count NUMBER(16) := 0;
      v_line VARCHAR2(1024);
      v_array apex_application_global.vc_arr2;
      fHandle UTL_FILE.FILE_TYPE  := UTL_FILE.FOPEN('OUTPUT_DIR', in_fileName, 'r');
  BEGIN
      IF UTL_FILE.IS_OPEN(fHandle) THEN
            LOOP
                BEGIN
                  UTL_FILE.GET_LINE(fHandle, v_line);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN EXIT;
                END;

                v_array := apex_util.string_to_table(v_line, ';');
                INSERT INTO regions_bckp VALUES ( v_array(1), v_array(2) );
                v_count := v_count + 1;
            END LOOP;
      END IF;

      UTL_FILE.FCLOSE(fHandle);
      COMMIT;
      RETURN v_count;

      EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Generic error - closing file');
                UTL_FILE.FCLOSE(fHandle);
            END;
  END;
  -- <<<<<<<<< PRIVATE DEFINITIONS - LOAD TABLES FROM FILES TO BACKUP TABLES >>>>>>>>> --


  -- >>>>>>>>> PUBLIC DEFINITION - LOAD DATA FROM BACKUP TABLES <<<<<<<<< --
  -- LOADS DATA FROM BCKP TABLE TO ORIGINAL ONE - EMPLOYEES
  PROCEDURE load_data(in_tableName IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    selectQuery VARCHAR2(256) := 'SELECT * FROM ' || in_tableName || ' ORDER BY 1';
  BEGIN
      DBMS_OUTPUT.PUT_LINE('load_data');
      CASE LOWER(in_tableName)
        WHEN 'employees_bckp' THEN copy_to_employees(selectQuery, in_commitOccurence, out_totalInserted);
        WHEN 'departments_bckp' THEN copy_to_departments(selectQuery, in_commitOccurence, out_totalInserted);
        WHEN 'countries_bckp' THEN copy_to_countries(selectQuery, in_commitOccurence, out_totalInserted);
        WHEN 'job_history_bckp' THEN copy_to_job_history(selectQuery, in_commitOccurence, out_totalInserted);
        WHEN 'jobs_bckp' THEN copy_to_jobs(selectQuery, in_commitOccurence, out_totalInserted);
        WHEN 'locations_bckp' THEN copy_to_locations(selectQuery, in_commitOccurence, out_totalInserted);
        WHEN 'regions_bckp' THEN copy_to_regions(selectQuery, in_commitOccurence, out_totalInserted);
        ELSE out_totalInserted := -2;
      END CASE;
  END;
  -- <<<<<<<<< PUBLIC DEFINITION - LOAD DATA FROM BACKUP TABLES >>>>>>>>> --

  -- >>>>>>>>> PRIVATE DEFINITIONS - COPY DATA FROM BACKUP TABLES <<<<<<<<< --
  -- COPY FROM EMPLOYEES_BCKP TO EMPLOYEES
  PROCEDURE copy_to_employees(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    v_row employees_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO v_row;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO employees
                VALUES (toNumber(v_row.employee_id), toVarchar(v_row.first_name), toVarchar(v_row.last_name), toVarchar(v_row.email), toVarchar(v_row.phone_number),
                        toDate(v_row.hire_date), toVarchar(v_row.job_id), toNumber(v_row.salary), toNumber(v_row.commission_pct), toNumber(v_row.manager_id), toNumber(v_row.department_id));


            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;

  -- COPY FROM departments_bckp TO departments
  PROCEDURE copy_to_departments(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    r_er departments_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO r_er;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO departments
                VALUES (toNumber(r_er.department_id), toVarchar(r_er.department_name), toNumber(r_er.manager_id), toNumber(r_er.location_id));


            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;

  -- COPY FROM countries_bckp TO countries
  PROCEDURE copy_to_countries(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    r_row countries_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO r_row;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO countries
                VALUES (toVarchar(r_row.country_id), toVarchar(r_row.country_name), toNumber(r_row.region_id));

            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;

  -- COPY FROM job_history_bckp TO job_history
  PROCEDURE copy_to_job_history(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    r_row job_history_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO r_row;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO job_history
                VALUES (toNumber(r_row.employee_id), toDate(r_row.start_date), toDate(r_row.end_date), toVarchar(r_row.job_id), toNumber(r_row.department_id));

            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;

  -- COPY FROM JOBS_BCKP TO JOBS
  PROCEDURE copy_to_jobs(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    v_row jobs_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO v_row;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO jobs
                VALUES (toVarchar(v_row.job_id), toVarchar(v_row.job_title), toNumber(v_row.min_salary), toNumber(v_row.max_salary));

            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;

  -- COPY FROM LOCATIONS_BCKP TO LOCATIONS
  PROCEDURE copy_to_locations(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    v_row locations_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO v_row;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO locations
                VALUES (toNumber(v_row.location_id), toVarchar(v_row.street_address), toVarchar(v_row.postal_code), toVarchar(v_row.city), toVarchar(v_row.state_province), toVarchar(v_row.country_id));

            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;

  -- COPY FROM REGIONS_BCKP TO REGIONS
  PROCEDURE copy_to_regions(selectQuery IN VARCHAR2, in_commitOccurence IN NUMBER, out_totalInserted OUT NUMBER)
  IS
    cv SYS_REFCURSOR;
    v_row regions_bckp%ROWTYPE;
    v_counter NUMBER(16) := 0;
    v_is_rollback BOOLEAN := FALSE;
  BEGIN
      out_totalInserted := 0;
      OPEN cv FOR selectQuery;
      LOOP
        <<insert_to>>
        FETCH cv INTO v_row;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
            v_counter := v_counter + 1;
            INSERT INTO regions
                VALUES (toNumber(v_row.region_id), toVarchar(v_row.region_name));

            IF MOD(v_counter, in_commitOccurence) = 0 AND (NOT v_is_rollback) THEN
                out_totalInserted := out_totalInserted + in_commitOccurence;
                v_is_rollback := FALSE;
                COMMIT;
            ELSIF MOD(v_counter, in_commitOccurence) = 0 THEN
                v_is_rollback := FALSE;
                ROLLBACK;
            END IF;

            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  v_is_rollback := TRUE;
                  CONTINUE;
                END;
        END insert_to;
      END LOOP;
      CLOSE cv;

      IF NOT v_is_rollback THEN
        out_totalInserted := out_totalInserted + MOD(v_counter, in_commitOccurence);
        COMMIT;
      ELSE
        ROLLBACK;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE('Error');
            out_totalInserted := -1;
          END;
  END;
  -- <<<<<<<<< PRIVATE DEFINITIONS - COPY DATA FROM BACKUP TABLES >>>>>>>>> --


  -- TRIES TO CAST A VARCHAR TO NUMBER
  FUNCTION toNumber(probablyNumber VARCHAR2) RETURN NUMBER
  IS
  BEGIN
    RETURN TO_NUMBER(probablyNumber);
  END;

  -- TRIES TO CAST A VARCHAR TO DATE
  FUNCTION toDate(probablyDate VARCHAR2) RETURN DATE
  IS
  BEGIN
    RETURN TO_DATE(probablyDate);
  END;

  -- TRIES TO CAST A VARCHAR TO VARCHAR
  FUNCTION toVarchar(probablyVarchar VARCHAR2) RETURN VARCHAR2
  IS
  BEGIN
    RETURN TO_CHAR(probablyVarchar);
  END;

  -- CHECKS DOES USER CAN USE file_dir DIRECTORY AS A DIRECTORY WHERE HE/SHE CAN SAVE/LOAD FILES
  FUNCTION is_user_directory(file_dir VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    FOR item IN (SELECT * FROM all_directories)
    LOOP
      IF item.directory_path = file_dir THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END;

END PKG_PS_FJ_FILE;
/
