
-- Author : Mrunmayee Kolhe
-- SQL Day2

ALTER WAREHOUSE compute_wh RESUME;
ALTER WAREHOUSE compute_wh SUSPEND;

-- Assignment A: MERGE 
-- Dataset Setup 
CREATE OR REPLACE TABLE SQL_ASSIGN_DB.PUBLIC.product_master_day2 ( 
    product_id NUMBER, 
    product_name VARCHAR(100), 
    category VARCHAR(50), 
    unit_price NUMBER(10, 2), 
    product_status VARCHAR(20), 
    source_updated_at TIMESTAMP_NTZ, 
    dw_created_at TIMESTAMP_NTZ, 
    dw_updated_at TIMESTAMP_NTZ 
); 
 
CREATE OR REPLACE TABLE SQL_ASSIGN_DB.PUBLIC.product_changes_day2 ( 
    product_id NUMBER, 
    product_name VARCHAR(100), 
    category VARCHAR(50), 
    unit_price NUMBER(10, 2), 
    product_status VARCHAR(20), 
    operation_type VARCHAR(10), 
    source_updated_at TIMESTAMP_NTZ 
); 

INSERT INTO SQL_ASSIGN_DB.PUBLIC.product_master_day2 VALUES 
    (101, 'Wireless Mouse', 'Accessories', 1200, 'ACTIVE', 
     '2026-09-01 08:00:00', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()), 
    (102, 'Mechanical Keyboard', 'Accessories', 4500, 'ACTIVE', 
     '2026-09-01 08:05:00', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()), 
    (103, '4K Monitor', 'Displays', 25000, 'ACTIVE', 
     '2026-09-01 08:10:00', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()); 
 
INSERT INTO SQL_ASSIGN_DB.PUBLIC.product_changes_day2 VALUES 
    (101, 'Wireless Mouse', 'Accessories', 1350, 'ACTIVE', 'UPDATE', '2026-09-03 09:00:00'), 
    (101, 'Wireless Mouse', 'Accessories', 1400, 'ACTIVE', 'UPDATE', '2026-09-03 11:00:00'), 
    (102, 'Mechanical Keyboard', 'Accessories', 4500, 'INACTIVE', 'DELETE', '2026-09-03 09:10:00'), 
    (104, 'Laptop Stand', 'Accessories', 1800, 'ACTIVE', 'INSERT', '2026-09-03 09:20:00'), 
    (105, 'USB Hub', 'Accessories', 2200, 'ACTIVE', 'INSERT', '2026-09-03 09:30:00'); 

-- Questions 
select * from sql_assign_db.public.product_master_day2;
select * from sql_assign_db.public.product_changes_day2;

-- 1. Create a deduplicated source that retains the latest source_updated_at for each product_id. 

MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    WHERE operation_type = 'UPDATE'
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id
-- 1. If the record exists in both tables, update the target
WHEN MATCHED THEN
    UPDATE SET unit_price = source.unit_price;

    
-- 2. Write a MERGE that updates newer records, inserts new records and physically deletes records marked DELETE. 
MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id

WHEN MATCHED AND operation_type = 'UPDATE'
    THEN UPDATE SET unit_price = source.unit_price
    
WHEN MATCHED AND operation_type = 'DELETE' 
    THEN DELETE
    
WHEN NOT MATCHED 
    THEN
        INSERT (product_id, product_name, category, unit_price, product_status) 
        VALUES (source.product_id, source.product_name, source.category, source.unit_price, source.product_status);

-- 3. Prevent updates when source values are identical to target values. 
MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    WHERE operation_type = 'UPDATE'
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id

WHEN MATCHED AND target.unit_price <> source.unit_price 
THEN
    UPDATE SET unit_price = source.unit_price;

-- 4. Make the MERGE safe to rerun and explain why the final state is idempotent. 
MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id

WHEN MATCHED AND operation_type = 'UPDATE'
    THEN UPDATE SET unit_price = source.unit_price
    
WHEN MATCHED AND operation_type = 'DELETE' 
    THEN DELETE

WHEN NOT MATCHED 
    THEN
        INSERT (product_id, product_name, category, unit_price, product_status, source_updated_at) 
        VALUES (source.product_id, source.product_name, source.category, source.unit_price, source.product_status, source.source_updated_at);

    
-- 5. Create validation queries for inserted, updated, deleted and unchanged records. 
MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id

WHEN MATCHED AND operation_type = 'UPDATE'
    THEN UPDATE SET unit_price = source.unit_price,
                    source_updated_at = current_timestamp()
    
WHEN MATCHED AND operation_type = 'DELETE' 
    THEN DELETE

WHEN NOT MATCHED 
    THEN
        INSERT (product_id, product_name, category, unit_price, product_status, source_updated_at) 
        VALUES (source.product_id, source.product_name, source.category, source.unit_price, source.product_status, source.source_updated_at;

-- 6. Add a late-arriving source row with an older timestamp and prove that the target is not overwritten. 
MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id

WHEN MATCHED AND source.operation_type = 'UPDATE' 
            AND source.source_updated_at > target.source_updated_at
    THEN UPDATE SET unit_price = source.unit_price,
                    source_updated_at = current_timestamp()
    
WHEN MATCHED AND source.operation_type = 'DELETE' 
    THEN DELETE

WHEN NOT MATCHED 
    THEN
        INSERT (product_id, product_name, category, unit_price, product_status, source_updated_at) 
        VALUES (source.product_id, source.product_name, source.category, source.unit_price, source.product_status, source.source_updated_at);

-- 7. Explain whether ALL BY NAME is appropriate for these two tables. 
MERGE INTO sql_assign_db.public.product_master_day2 target
USING (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY source_updated_at DESC) as rn
    FROM sql_assign_db.public.product_changes_day2 
    WHERE operation_type = 'UPDATE'
    QUALIFY rn = 1

) source
ON target.product_id = source.product_id

WHEN MATCHED THEN
    UPDATE ALL BY NAME
WHEN NOT MATCHED THEN
    INSERT ALL BY NAME;
    
-- 8. Create a one-row audit summary showing source count, distinct source keys, duplicate keys and target count.
WITH src_cte AS (    
    SELECT
        COUNT(*) as source_count,
        COUNT(DISTINCT product_id) as no_of_distinct_src_keys
    FROM sql_assign_db.public.product_changes_day2 
),
target_cte as (
    SELECT
        COUNT(*) as target_count
    FROM sql_assign_db.public.product_master_day2 
)
SELECT
    s.source_count,
    s.no_of_distinct_src_keys,
    s.source_count - s.no_of_distinct_src_keys AS duplicate_keys,
    t.target_count
FROM src_cte s
CROSS JOIN target_cte t;

-- Assignment B: Snowflake Functions 
-- Dataset Setup 
CREATE OR REPLACE TABLE service_requests_day2 ( 
    request_id NUMBER, 
    requester_name VARCHAR(100), 
    requester_email VARCHAR(150), 
    opened_at TIMESTAMP_NTZ, 
    closed_at TIMESTAMP_NTZ, 
    priority VARCHAR(20), 
    estimated_hours VARCHAR(20), 
    description VARCHAR(500) 
); 

INSERT INTO service_requests_day2 VALUES 
    (1, '  aditi sharma ', 'ADITI@EXAMPLE.COM', '2026-09-01 09:00:00', 
     '2026-09-01 15:30:00', 'high', '6.5', 'Password reset and account review'), 
    (2, 'VIKRAM RAO', 'vikram@sample.org', '2026-09-02 10:00:00', 
     NULL, 'medium', 'not available', 'Laptop setup'), 
    (3, 'Neha Singh', NULL, '2026-09-03 08:15:00', 
     '2026-09-05 11:45:00', NULL, '12', 'Data access request'), 
    (4, 'Arjun Mehta', 'arjun@example.com', '2026-09-04 14:00:00', 
     '2026-09-04 16:00:00', 'low', '2', 'Software installation'); 

-- Questions
-- 1. Standardize requester_name using TRIM and INITCAP. 
SELECT 
    INITCAP(TRIM(requester_name)) as requester_name_standardised
FROM SQL_ASSIGN_DB.PUBLIC.SERVICE_REQUESTS_DAY2;

-- 2. Replace missing priority with UNKNOWN and convert all priority values to uppercase. 
SELECT 
    request_id,
    UPPER(COALESCE(priority, 'UNKNOWN')) as priority
FROM SQL_ASSIGN_DB.PUBLIC.SERVICE_REQUESTS_DAY2;

-- 3. Use TRY_TO_NUMBER to convert estimated_hours and identify invalid values. 
SELECT 
    request_id,
    estimated_hours,
    TRY_TO_NUMBER(estimated_hours) as data_validation
FROM SQL_ASSIGN_DB.PUBLIC.SERVICE_REQUESTS_DAY2;

-- 4. Calculate resolution hours for closed requests using DATEDIFF. 
SELECT 
    request_id,
    closed_at, opened_at,
    DATEDIFF(HOUR, opened_at, closed_at) as resolution_hours
FROM SQL_ASSIGN_DB.PUBLIC.SERVICE_REQUESTS_DAY2;

-- 5. Calculate the Monday-start week for opened_at using DATE_TRUNC. 
SELECT 
    request_id,
    DATE_TRUNC('week', opened_at) as monday_start_week
FROM SQL_ASSIGN_DB.PUBLIC.SERVICE_REQUESTS_DAY2;

-- 6. Create a scalar SQL UDF named normalize_priority that returns HIGH, MEDIUM, LOW or UNKNOWN. 
CREATE OR REPLACE FUNCTION normalize_priority(priority VARCHAR)
RETURNS VARCHAR
AS
$$
    UPPER(priority)
$$;

-- Calling the UDF
SELECT request_id, normalize_priority(priority) as n_priority FROM SERVICE_REQUESTS_DAY2;

-- 7. Use both UDFs in one SELECT statement. 
CREATE OR REPLACE FUNCTION cap_func(requester_name VARCHAR)
RETURNS VARCHAR
AS
$$
    INITCAP(requester_name)
$$;

CREATE OR REPLACE FUNCTION timestamp_to_hour(opened_at timestamp, closed_at timestamp)
RETURNS INTEGER
AS
$$
    DATEDIFF('HOUR', opened_at, closed_at)
$$;

SELECT 
    request_id, 
    cap_func(requester_name),
    timestamp_to_hour(opened_at, closed_at)
as n_priority FROM SERVICE_REQUESTS_DAY2;

-- 8. Show and describe the two UDFs, including their argument signatures. 
CREATE OR REPLACE FUNCTION normalize_priority(priority VARCHAR)
RETURNS VARCHAR
AS
$$
    UPPER(priority)
$$;

CREATE OR REPLACE FUNCTION timestamp_to_hour(opened_at timestamp, closed_at timestamp)
RETURNS INTEGER
AS
$$
    DATEDIFF('HOUR', opened_at, closed_at)
$$;

SELECT 
    request_id, 
    normalize_priority(priority) as n_priority,
    timestamp_to_hour(opened_at, closed_at) as resolution_hours
FROM SERVICE_REQUESTS_DAY2;
-- Challenge: Create a reusable function that masks the local part of an email address while preserving the domain. Define the expected behavior for NULL and invalid email values.

CREATE OR REPLACE FUNCTION mask_mail(email VARCHAR)
RETURNS VARCHAR
AS
$$
    CASE 
    -- 1. Handle NULL
    WHEN email IS NULL THEN NULL
    
    -- 2. Handle Invalid (No '@' or multiple '@')
    WHEN REGEXP_COUNT(email, '@') != 1 THEN 'INVALID_EMAIL'
    
    -- 3. Replace all characters before the @ with asterisks matching its exact length
    ELSE LOWER(REPEAT('*', LENGTH(SPLIT_PART(email, '@', 1))) 
         || '@' || SPLIT_PART(email, '@', 2))
  END
$$;

SELECT 
    request_id, 
    requester_name,
    mask_mail(requester_email) as masked_mail
FROM SERVICE_REQUESTS_DAY2;

-- Assignment C: SQL Stored Procedures 
-- Dataset Setup 
CREATE OR REPLACE TABLE inventory_stage_day2 ( 
    item_id NUMBER, 
    item_name VARCHAR(100), 
    quantity NUMBER, 
    unit_cost NUMBER(10, 2), 
    source_updated_at TIMESTAMP_NTZ 
); 
 
CREATE OR REPLACE TABLE inventory_target_day2 ( 
    item_id NUMBER, 
    item_name VARCHAR(100), 
    quantity NUMBER, 
    unit_cost NUMBER(10, 2), 
    source_updated_at TIMESTAMP_NTZ, 
    dw_updated_at TIMESTAMP_NTZ 
); 
 
CREATE OR REPLACE TABLE inventory_audit_day2 ( 
    run_id VARCHAR(50), 
    process_name VARCHAR(100), 
    run_status VARCHAR(20), 
    rows_affected NUMBER, 
    message VARCHAR(500), 
    logged_at TIMESTAMP_NTZ 
); 

INSERT INTO inventory_target_day2 VALUES 
    (1, 'Mouse', 20, 900, '2026-09-01 08:00:00', CURRENT_TIMESTAMP()), 
    (2, 'Keyboard', 15, 3200, '2026-09-01 08:05:00', CURRENT_TIMESTAMP()); 
 
INSERT INTO inventory_stage_day2 VALUES 
    (1, 'Mouse', 25, 950, '2026-09-04 09:00:00'), 
    (2, 'Keyboard', -3, 3200, '2026-09-04 09:05:00'), 
    (3, 'Monitor', 8, 21000, '2026-09-04 09:10:00'); 

-- Questions
-- 1. Create a procedure that returns the number of rows in inventory_stage_day2. 
CREATE OR REPLACE PROCEDURE no_of_rows()
RETURNS INTEGER
LANGUAGE SQL
AS
$$
BEGIN
    RETURN 
        (SELECT count(*) as counted_rows
        FROM SQL_ASSIGN_DB.PUBLIC.INVENTORY_STAGE_DAY2);
END;
$$;

CALL no_of_rows();

-- 2. Create a validation procedure that returns FAILED when quantity is negative or unit_cost is NULL. 
CREATE OR REPLACE PROCEDURE data_validation_proc()
RETURNS TABLE(process_status string)
LANGUAGE SQL
AS
$$
DECLARE result_set RESULTSET;

BEGIN

        result_set := (SELECT 
            CASE 
                WHEN quantity < 0 OR unit_cost IS NULL THEN 'FAILED'
                ELSE 'PASSED'
            END AS process_status
        FROM SQL_ASSIGN_DB.PUBLIC.INVENTORY_STAGE_DAY2);
    RETURN TABLE(result_set);
END;
$$;

CALL data_validation_proc();

-- 3. Create a MERGE procedure that updates newer items and inserts new items. 
CREATE OR REPLACE PROCEDURE merge_proc()
RETURNS STRING
LANGUAGE SQL
AS
$$

BEGIN
    MERGE INTO SQL_ASSIGN_DB.PUBLIC.inventory_target_day2 target
    USING SQL_ASSIGN_DB.PUBLIC.inventory_stage_day2 source
    ON target.item_id = source.item_id
    WHEN MATCHED THEN
        UPDATE SET target.unit_cost = source.unit_cost, 
                    target.quantity = source.quantity
    WHEN NOT MATCHED THEN
        INSERT (item_id, 
                item_name, 
                quantity, 
                unit_cost)
        VALUES (source.item_id, 
                source.item_name, 
                source.quantity, 
                source.unit_cost);
RETURN 'Merge successful!';
END;
$$;

CALL merge_proc();
SELECT * FROM SQL_ASSIGN_DB.PUBLIC.INVENTORY_TARGET_DAY2;

-- 4. Add an audit record after a successful MERGE. 
CREATE OR REPLACE PROCEDURE merge_proc()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE rows_total number;
BEGIN
    MERGE INTO SQL_ASSIGN_DB.PUBLIC.inventory_target_day2 target
    USING SQL_ASSIGN_DB.PUBLIC.inventory_stage_day2 source
    ON target.item_id = source.item_id
    WHEN MATCHED THEN
        UPDATE SET target.unit_cost = source.unit_cost, 
                    target.quantity = source.quantity,
                    target.source_updated_at = source.source_updated_at,
                    target.dw_updated_at = CURRENT_TIMESTAMP()
    WHEN NOT MATCHED THEN
        INSERT (item_id, 
                item_name, 
                quantity, 
                unit_cost,
                source_updated_at,
                dw_updated_at)
        VALUES (source.item_id, 
                source.item_name, 
                source.quantity, 
                source.unit_cost,
                source.source_updated_at,
                current_timestamp());
                
    rows_total := SQLROWCOUNT;
    
    INSERT INTO SQL_ASSIGN_DB.PUBLIC.inventory_audit_day2
    (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES
    (
        'a92mxk',
        'merge_proc',
        'SUCCESS',
        :rows_total,
        'Inventory MERGE completed successfully',
        CURRENT_TIMESTAMP()
    );
RETURN 'Merge successful!; Audit record added';
END;
$$;

CALL merge_proc();
SELECT * FROM SQL_ASSIGN_DB.PUBLIC.INVENTORY_TARGET_DAY2;

-- 5. Capture SQLROWCOUNT and include it in the returned message.  
CREATE OR REPLACE PROCEDURE merge_proc()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE rows_total NUMBER;
BEGIN
    MERGE INTO SQL_ASSIGN_DB.PUBLIC.inventory_target_day2 target
    USING SQL_ASSIGN_DB.PUBLIC.inventory_stage_day2 source
    ON target.item_id = source.item_id
    WHEN MATCHED THEN
        UPDATE SET target.unit_cost = source.unit_cost, 
                    target.quantity = source.quantity
    WHEN NOT MATCHED THEN
        INSERT (item_id, 
                item_name, 
                quantity, 
                unit_cost)
        VALUES (source.item_id, 
                source.item_name, 
                source.quantity, 
                source.unit_cost);
        rows_total := SQLROWCOUNT;
RETURN 'Merge successful! and row_count is ' || rows_total;
END;
$$;

CALL merge_proc();
-- NOTE: SQLROWCOUNT is a global system variable to return row count of latest executed query. 

-- 6. Add explicit transaction handling so the MERGE and success audit record commit together. 
CREATE OR REPLACE PROCEDURE merge_proc()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE rows_total number;
BEGIN

    BEGIN TRANSACTION;

    MERGE INTO SQL_ASSIGN_DB.PUBLIC.inventory_target_day2 target
    USING SQL_ASSIGN_DB.PUBLIC.inventory_stage_day2 source
    ON target.item_id = source.item_id
    WHEN MATCHED THEN
        UPDATE SET target.unit_cost = source.unit_cost, 
                    target.quantity = source.quantity,
                    target.source_updated_at = source.source_updated_at,
                    target.dw_updated_at = CURRENT_TIMESTAMP()
    WHEN NOT MATCHED THEN
        INSERT (item_id, 
                item_name, 
                quantity, 
                unit_cost,
                source_updated_at,
                dw_updated_at)
        VALUES (source.item_id, 
                source.item_name, 
                source.quantity, 
                source.unit_cost,
                source.source_updated_at,
                current_timestamp());
                
    rows_total := SQLROWCOUNT;
    
    INSERT INTO SQL_ASSIGN_DB.PUBLIC.inventory_audit_day2
    (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES
    (
        'a92mxk',
        'merge_proc',
        'SUCCESS',
        :rows_total,
        'Inventory MERGE completed successfully',
        CURRENT_TIMESTAMP()
    );

    COMMIT;
    RETURN 'Merge successful!; Audit record added';

EXCEPTION
    -- 5. Error handling block
    WHEN OTHER THEN
        -- Roll back the entire transaction if any step fails
        ROLLBACK;
        
        -- Rethrow or log the error message
        RAISE; 
END;
$$;

call MERGE_PROC();

-- 7. Add exception handling that rolls back and writes a failure audit record. 
CREATE OR REPLACE PROCEDURE merge_proc()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE rows_total number;
BEGIN

    BEGIN TRANSACTION;

    MERGE INTO SQL_ASSIGN_DB.PUBLIC.inventory_target_day2 target
    USING SQL_ASSIGN_DB.PUBLIC.inventory_stage_day2 source
    ON target.item_id = source.item_id
    WHEN MATCHED THEN
        UPDATE SET target.unit_cost = source.unit_cost, 
                    target.quantity = source.quantity,
                    target.source_updated_at = source.source_updated_at,
                    target.dw_updated_at = CURRENT_TIMESTAMP()
    WHEN NOT MATCHED THEN
        INSERT (item_id, 
                item_name, 
                quantity, 
                unit_cost,
                source_updated_at,
                dw_updated_at)
        VALUES (source.item_id, 
                source.item_name, 
                source.quantity, 
                source.unit_cost,
                source.source_updated_at,
                current_timestamp());
                
    rows_total := SQLROWCOUNT;
    
    INSERT INTO SQL_ASSIGN_DB.PUBLIC.inventory_audit_day2
    (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES
    (
        'a92mxk',
        'merge_proc',
        'SUCCESS',
        :rows_total,
        'Inventory MERGE completed successfully',
        CURRENT_TIMESTAMP()
    );

    COMMIT;
    RETURN 'Merge successful!; Audit record added';

EXCEPTION
    -- 5. Error handling block
    WHEN OTHER THEN
        -- Roll back the entire transaction if any step fails
        ROLLBACK;
        INSERT INTO SQL_ASSIGN_DB.PUBLIC.inventory_audit_day2
    (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES
    (
        'a92mxk',
        'merge_proc',
        'FAILURE',
        '0',
        'Inventory MERGE FAILED',
        CURRENT_TIMESTAMP()
    );

        -- Rethrow or log the error message
        RAISE; 
END;
$$;
call MERGE_PROC();

-- 8. Create a procedure that returns a table containing items whose inventory value exceeds a supplied amount. 

-- 9. Create one caller-rights version and one owner-rights version, then explain the access difference. Call each procedure and verify the resulting target and audit tables.

-- Challenge: Create one orchestration procedure that validates the stage, stops when validation fails, otherwise runs the inventory MERGE and returns a concise load summary. 

-- Final Integrated Assignment 

-- 1. Create a change feed for inventory that includes INSERT, UPDATE and DELETE operations. 
CREATE OR REPLACE STREAM inventory_change_feed
ON TABLE SQL_ASSIGN_DB.PUBLIC.inventory_target_day2;

-- 2. Create a SQL UDF that calculates inventory value as quantity multiplied by unit cost. 
CREATE OR REPLACE FUNCTION INVENTORY_VALUE (QUANTITY NUMBER, UNIT_COST NUMBER)
RETURNS NUMBER(38, 2)
AS
$$
        QUANTITY * UNIT_COST
$$;

SELECT SUM(INVENTORY_VALUE(QUANTITY, UNIT_COST)) AS TOTAL_INVENTORY_VALUE
FROM SQL_ASSIGN_DB.PUBLIC.inventory_target_day2;

-- 3. Create a procedure that deduplicates the latest change per item, validates negative quantities, applies the MERGE and writes an audit record. 
CREATE OR REPLACE PROCEDURE process_inventory_changes()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    v_run_id VARCHAR(50) DEFAULT UUID_STRING();
    v_rows_affected NUMBER DEFAULT 0;
    v_rows_rejected NUMBER DEFAULT 0;

BEGIN

    -- Deduplicate changes and keep the latest change for each item
    CREATE OR REPLACE TEMPORARY TABLE latest_inventory_changes AS
    SELECT
        item_id,
        item_name,
        quantity,
        unit_cost,
        source_updated_at,
        METADATA$ACTION AS change_type,
        METADATA$ISUPDATE AS is_update
    FROM inventory_change_feed
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY item_id
        ORDER BY source_updated_at DESC
    ) = 1;


    -- Validate negative quantities
    SELECT COUNT(*)
    INTO :v_rows_rejected
    FROM latest_inventory_changes
    WHERE quantity < 0;


    -- Apply valid changes
    MERGE INTO inventory_target_day2 AS target
    USING (
        SELECT
            item_id,
            item_name,
            quantity,
            unit_cost,
            source_updated_at,
            change_type
        FROM latest_inventory_changes
        WHERE quantity >= 0
    ) AS source

    ON target.item_id = source.item_id

    -- DELETE
    WHEN MATCHED
         AND source.change_type = 'DELETE'
    THEN DELETE

    -- UPDATE
    WHEN MATCHED
    THEN UPDATE SET
        target.item_name = source.item_name,
        target.quantity = source.quantity,
        target.unit_cost = source.unit_cost,
        target.source_updated_at = source.source_updated_at,
        target.dw_updated_at = CURRENT_TIMESTAMP()

    -- INSERT
    WHEN NOT MATCHED
         AND source.change_type = 'INSERT'
    THEN INSERT (
        item_id,
        item_name,
        quantity,
        unit_cost,
        source_updated_at,
        dw_updated_at
    )
    VALUES (
        source.item_id,
        source.item_name,
        source.quantity,
        source.unit_cost,
        source.source_updated_at,
        CURRENT_TIMESTAMP()
    );


    -- Number of rows processed
    v_rows_affected := SQLROWCOUNT;


    -- Audit successful run
    INSERT INTO inventory_audit_day2 (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES (
        :v_run_id,
        'PROCESS_INVENTORY_CHANGES',
        'SUCCESS',
        :v_rows_affected,
        'Inventory changes processed successfully. Rejected rows: '
            || :v_rows_rejected,
        CURRENT_TIMESTAMP()
    );


    RETURN 'SUCCESS - Run ID: ' || v_run_id;


EXCEPTION
    WHEN OTHER THEN

        INSERT INTO inventory_audit_day2 (
            run_id,
            process_name,
            run_status,
            rows_affected,
            message,
            logged_at
        )
        VALUES (
            :v_run_id,
            'PROCESS_INVENTORY_CHANGES',
            'FAILED',
            0,
            SQLERRM,
            CURRENT_TIMESTAMP()
        );

        RETURN 'FAILED - Run ID: ' || v_run_id || ' - ' || SQLERRM;

END;
$$;

CALL process_inventory_changes();

-- 4. Return a table containing item_id, operation outcome and calculated inventory value. 
CREATE OR REPLACE PROCEDURE process_inventory_changes()
RETURNS TABLE (
    item_id NUMBER,
    operation_outcome VARCHAR,
    inventory_value NUMBER(18,2)
)
LANGUAGE SQL
AS
$$
DECLARE
    v_run_id VARCHAR(50) DEFAULT UUID_STRING();

BEGIN

    CREATE OR REPLACE TEMPORARY TABLE latest_inventory_changes AS
    SELECT
        item_id,
        item_name,
        quantity,
        unit_cost,
        source_updated_at,
        METADATA$ACTION AS change_type,
        METADATA$ISUPDATE AS is_update
    FROM inventory_change_feed
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY item_id
        ORDER BY source_updated_at DESC
    ) = 1;


    -- Perform MERGE
    MERGE INTO inventory_target_day2 AS target
    USING (
        SELECT *
        FROM latest_inventory_changes
        WHERE quantity >= 0
    ) AS source

    ON target.item_id = source.item_id

    WHEN MATCHED
         AND source.change_type = 'DELETE'
    THEN DELETE

    WHEN MATCHED
    THEN UPDATE SET
        target.item_name = source.item_name,
        target.quantity = source.quantity,
        target.unit_cost = source.unit_cost,
        target.source_updated_at = source.source_updated_at,
        target.dw_updated_at = CURRENT_TIMESTAMP()

    WHEN NOT MATCHED
         AND source.change_type = 'INSERT'
    THEN INSERT (
        item_id,
        item_name,
        quantity,
        unit_cost,
        source_updated_at,
        dw_updated_at
    )
    VALUES (
        source.item_id,
        source.item_name,
        source.quantity,
        source.unit_cost,
        source.source_updated_at,
        CURRENT_TIMESTAMP()
    );


    -- Audit
    INSERT INTO inventory_audit_day2 (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES (
        :v_run_id,
        'PROCESS_INVENTORY_CHANGES',
        'SUCCESS',
        SQLROWCOUNT,
        'Inventory changes processed successfully',
        CURRENT_TIMESTAMP()
    );


    -- Return result
    RETURN TABLE (
        SELECT
            item_id,

            CASE
                WHEN change_type = 'DELETE'
                    THEN 'DELETED'

                WHEN is_update = TRUE
                    THEN 'UPDATED'

                WHEN change_type = 'INSERT'
                    THEN 'INSERTED'

                ELSE 'UNKNOWN'
            END AS operation_outcome,

            CASE
                WHEN change_type = 'DELETE'
                    THEN 0

                WHEN quantity < 0
                    THEN 0

                ELSE quantity * unit_cost
            END AS inventory_value

        FROM latest_inventory_changes
    );

END;
$$;
CALL process_inventory_changes();

-- 5. Demonstrate a successful run and a failed validation run.
CREATE OR REPLACE PROCEDURE process_inventory_changes()
RETURNS TABLE (
    item_id NUMBER,
    operation_outcome VARCHAR,
    inventory_value NUMBER(18,2)
)
LANGUAGE SQL
AS
$$
DECLARE
    v_run_id VARCHAR(50) DEFAULT UUID_STRING();
    v_result RESULTSET;

BEGIN

    -- 1. Get latest change for each item
    CREATE OR REPLACE TEMPORARY TABLE latest_inventory_changes AS
    SELECT
        item_id,
        item_name,
        quantity,
        unit_cost,
        source_updated_at,
        METADATA$ACTION AS change_type,
        METADATA$ISUPDATE AS is_update
    FROM inventory_change_feed
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY item_id
        ORDER BY source_updated_at DESC
    ) = 1;


    -- 2. Validate negative quantities
    IF (
        EXISTS (
            SELECT 1
            FROM latest_inventory_changes
            WHERE quantity < 0
        )
    ) THEN

        INSERT INTO inventory_audit_day2 (
            run_id,
            process_name,
            run_status,
            rows_affected,
            message,
            logged_at
        )
        VALUES (
            :v_run_id,
            'PROCESS_INVENTORY_CHANGES',
            'FAILED',
            0,
            'Validation failed: negative quantity detected',
            CURRENT_TIMESTAMP()
        );

        -- Stop the procedure
        v_result := (
            SELECT
                item_id,
                'REJECTED' AS operation_outcome,
                0::NUMBER(18,2) AS inventory_value
            FROM latest_inventory_changes
            WHERE quantity < 0
        );

        RETURN TABLE(v_result);

    END IF;


    -- 3. Apply valid changes
    MERGE INTO inventory_target_day2 AS target
    USING latest_inventory_changes AS source

    ON target.item_id = source.item_id

    -- DELETE
    WHEN MATCHED
         AND source.change_type = 'DELETE'
    THEN DELETE

    -- UPDATE
    WHEN MATCHED
    THEN UPDATE SET
        target.item_name = source.item_name,
        target.quantity = source.quantity,
        target.unit_cost = source.unit_cost,
        target.source_updated_at = source.source_updated_at,
        target.dw_updated_at = CURRENT_TIMESTAMP()

    -- INSERT
    WHEN NOT MATCHED
         AND source.change_type = 'INSERT'
    THEN INSERT (
        item_id,
        item_name,
        quantity,
        unit_cost,
        source_updated_at,
        dw_updated_at
    )
    VALUES (
        source.item_id,
        source.item_name,
        source.quantity,
        source.unit_cost,
        CURRENT_TIMESTAMP(),
        CURRENT_TIMESTAMP()
    );


    -- 4. Audit successful run
    INSERT INTO inventory_audit_day2 (
        run_id,
        process_name,
        run_status,
        rows_affected,
        message,
        logged_at
    )
    VALUES (
        :v_run_id,
        'PROCESS_INVENTORY_CHANGES',
        'SUCCESS',
        SQLROWCOUNT,
        'Inventory changes processed successfully',
        CURRENT_TIMESTAMP()
    );


    -- 5. Return operation result
    v_result := (
        SELECT
            item_id,

            CASE
                WHEN change_type = 'DELETE'
                    THEN 'DELETED'
                WHEN is_update = TRUE
                    THEN 'UPDATED'
                WHEN change_type = 'INSERT'
                    THEN 'INSERTED'
                ELSE 'UNKNOWN'
            END AS operation_outcome,

            CASE
                WHEN change_type = 'DELETE'
                    THEN 0
                ELSE quantity * unit_cost
            END AS inventory_value

        FROM latest_inventory_changes
    );

    RETURN TABLE(v_result);

END;
$$;
CALL process_inventory_changes();

-- 6. Provide validation queries proving target uniqueness, correct audit status and safe rerun behavior. 