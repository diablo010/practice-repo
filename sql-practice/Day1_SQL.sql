-- Author: Mrunmayee Kolhe
-- SQL training 
-- Day 1

use warehouse compute_wh;
use database sql_assign_db;

ALTER WAREHOUSE compute_wh RESUME;
ALTER WAREHOUSE compute_wh SUSPEND;

-- table creation
CREATE OR REPLACE TABLE student_results ( 
    student_id   NUMBER, 
    student_name VARCHAR(100), 
    college_name VARCHAR(100), 
    course_name  VARCHAR(100), 
    score        NUMBER(5, 2), 
    exam_date    DATE 
); 

INSERT INTO student_results VALUES 
    (1, 'Aditi', 'College A', 'SQL', 88, '2025-06-01'), 
    (2, 'Vikram', 'College B', 'SQL', 72, '2025-06-01'), 
    (3, 'Neha', 'College A', 'Python', 91, '2025-06-05'), 
    (4, 'Arjun', 'College C', 'SQL', 64, '2025-06-01'), 
    (5, 'Sara', 'College B', 'Python', 79, '2025-06-05'), 
    (6, 'Dev', 'College A', 'SQL', 95, '2025-06-01'); 

-- SQL Standards and Query Structure 
-- 1. Display student name, course and score using meaningful output aliases. 
SELECT
    student_name AS Name, 
    course_name AS Course, 
    score AS "SCORE(out of 100)"
FROM SQL_ASSIGN_DB.PUBLIC.student_results;

-- 2. Return SQL learners with a score of at least 70, ordered from highest to lowest score. 
SELECT
    student_id AS ID,
    student_name AS Name,
    score
FROM SQL_ASSIGN_DB.PUBLIC.student_results
WHERE score >= 70
ORDER BY score DESC;

-- 3. Calculate the number of students and average score by course. 
SELECT
    course_name,
    count(distinct student_id) as no_of_students,
    round(avg(score), 2) as avg_score
FROM SQL_ASSIGN_DB.PUBLIC.student_results
GROUP BY course_name;

-- 4. Return courses whose average score is greater than 75. 
SELECT
    course_name,
    round(avg(score), 2) as avg_score
FROM SQL_ASSIGN_DB.PUBLIC.student_results
GROUP BY course_name
HAVING round(avg(score), 2) > 75;

-- Challenge question
-- Without using SELECT *, return the top three highest-scoring students across all courses.
SELECT
    student_id,
    student_name,
    course_name,
    score
FROM SQL_ASSIGN_DB.PUBLIC.student_results
ORDER BY score desc
limit 3;

-- Joins
-- DDL
CREATE OR REPLACE TABLE trainee_departments ( 
    department_id   NUMBER, 
    department_name VARCHAR(50) 
); 
 
CREATE OR REPLACE TABLE trainees ( 
    trainee_id    NUMBER, 
    trainee_name  VARCHAR(100), 
    department_id NUMBER 
); 
 
CREATE OR REPLACE TABLE training_modules ( 
    module_id   NUMBER, 
    module_name VARCHAR(100) 
); 
 
CREATE OR REPLACE TABLE trainee_completion ( 
    trainee_id NUMBER, 
    module_id  NUMBER, 
    status     VARCHAR(20) 
); 

INSERT INTO trainee_departments VALUES 
    (10, 'Data'), (20, 'Finance'), (30, 'Operations'), (40, 'HR'); 
INSERT INTO trainees VALUES 
    (1, 'Aditi', 10), (2, 'Vikram', 20), (3, 'Neha', 10), 
    (4, 'Arjun', NULL), (5, 'Sara', 50); 
INSERT INTO training_modules VALUES 
    (101, 'SQL Basics'), (102, 'Data Quality'), (103, 'Snowflake Basics'); 
INSERT INTO trainee_completion VALUES 
    (1, 101, 'Completed'), (1, 102, 'Completed'), 
    (2, 101, 'In Progress'), (3, 101, 'Completed'), 
    (5, 103, 'Completed'); 

-- Questions
--  1. Display every trainee with the department name, retaining trainees without a valid department. 
SELECT 
    t.trainee_id,
    t.trainee_name,
    td.department_id
FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEE_DEPARTMENTS td
ON t.department_id = td.department_id;

-- 2. Return only trainees that have a valid department. 
SELECT 
    t.trainee_id,
    t.trainee_name,
    td.department_id
FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEE_DEPARTMENTS td
ON t.department_id = td.department_id;

-- 3. Identify departments that currently have no trainees. 
SELECT 
    td.department_id
FROM SQL_ASSIGN_DB.PUBLIC.TRAINEE_DEPARTMENTS td
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEES t
ON t.department_id = td.department_id
where trainee_id is null;

-- 4. Display trainee names, module names and completion status. 
SELECT 
    t.trainee_name,
    tm.module_name,
    tc.status
FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEE_COMPLETION tc
ON t.trainee_id = tc.trainee_id
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINING_MODULES tm
ON tc.module_id = tm.module_id;

-- 5. Identify trainees who have not started any module. 
SELECT 
    t.trainee_id,
    t.trainee_name
FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEE_COMPLETION tc
ON t.trainee_id = tc.trainee_id
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINING_MODULES tm
ON tc.module_id = tm.module_id
WHERE tc.module_id IS NULL;

-- 6. Count completed modules for every trainee, including those with zero completions. 
SELECT 
    t.trainee_id,
    t.trainee_name,
    sum(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as no_of_completed_modules,
FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEE_COMPLETION tc
ON t.trainee_id = tc.trainee_id
GROUP BY t.trainee_id, 
         t.trainee_name;


-- Challenge question
-- Create a matrix containing every trainee-module combination and show Completed, In Progress or Not Started.
with all_flat_combos as (
    SELECT 
        t.trainee_id,
        t.trainee_name,
        tm.module_id
    FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
    CROSS JOIN SQL_ASSIGN_DB.PUBLIC.TRAINING_MODULES tm
)
-- trainee_with_mod as (
--     SELECT 
--         t.trainee_id,
--         t.trainee_name,
--         tm.module_id,
--         tc.status
--     FROM SQL_ASSIGN_DB.PUBLIC.TRAINEES t
--     LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINEE_COMPLETION tc
--     ON t.trainee_id = tc.trainee_id
--     LEFT JOIN SQL_ASSIGN_DB.PUBLIC.TRAINING_MODULES tm
--     ON tc.module_id = tm.module_id
-- )
select 
    afc.trainee_id,
    afc.module_id,
    tc.status
from all_flat_combos afc
left join trainee_completion tc
on afc.trainee_id = tc.trainee_id
    AND afc.module_id = tc.module_id;

-- select * from SQL_ASSIGN_DB.PUBLIC.TRAINEE_COMPLETION;

-- WINDOW FUNCTIONS
CREATE OR REPLACE TABLE employee_scores ( 
    employee_id   NUMBER, 
    employee_name VARCHAR(100), 
    team_name     VARCHAR(50), 
    assessment_no NUMBER, 
    score         NUMBER(5, 2) 
); 

INSERT INTO employee_scores VALUES 
    (1, 'Aditi', 'Alpha', 1, 72), (1, 'Aditi', 'Alpha', 2, 84), 
    (2, 'Vikram', 'Alpha', 1, 84), (2, 'Vikram', 'Alpha', 2, 88), 
    (3, 'Neha', 'Beta', 1, 91), (3, 'Neha', 'Beta', 2, 89), 
    (4, 'Arjun', 'Beta', 1, 67), (4, 'Arjun', 'Beta', 2, 74), 
    (5, 'Sara', 'Alpha', 1, 84), (5, 'Sara', 'Alpha', 2, 90);

-- Questions
-- 1. For assessment 2, rank employees by score within each team using RANK. 
SELECT 
    team_name,
    employee_id,
    employee_name,
    score,
    RANK() OVER(PARTITION BY team_name ORDER BY score desc) as rank_by_score
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES;

-- 2. Repeat using DENSE_RANK and ROW_NUMBER, then explain the difference. 
SELECT 
    team_name,
    employee_id,
    employee_name,
    score,
    DENSE_RANK() OVER(PARTITION BY team_name ORDER BY score desc) as rank_by_score
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES;

SELECT 
    team_name,
    employee_id,
    employee_name,
    score,
    ROW_NUMBER() OVER(PARTITION BY team_name ORDER BY score desc) as rank_by_score
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES;

-- 3. Show each assessment score together with the employee’s average score. 
SELECT 
    employee_id,
    employee_name,
    score,
    AVG(score) OVER (PARTITION BY employee_id) as avg_score
 FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES;

-- 4. Calculate a running total of scores for each employee ordered by assessment number. 
SELECT 
    employee_id,
    employee_name,
    assessment_no,
    score,
    SUM(score) OVER (PARTITION BY employee_id ORDER BY assessment_no) as running_total
 FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES;
 
-- 5. Use LAG to show the previous assessment score and calculate improvement. 
SELECT 
    employee_id,
    employee_name,
    assessment_no,
    score,
    LAG(score) OVER (PARTITION BY employee_id ORDER BY assessment_no) as prev_score,
    score - LAG(score) OVER (PARTITION BY employee_id ORDER BY assessment_no) as improvement,
    
 FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES;
 
-- 6. Return the highest-scoring employee in each team for assessment 2. 
SELECT 
    team_name,
    employee_id,
    employee_name,
    assessment_no,
    score,
    row_number() OVER (PARTITION BY team_name ORDER BY score DESC) as highest_scoring_emp
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES
WHERE assessment_no = 2
QUALIFY highest_scoring_emp = 1;

-- Challenge question
--Return the two highest-scoring employees per team for assessment 2. 
SELECT 
    team_name,
    employee_id,
    employee_name,
    assessment_no,
    score,
    row_number() OVER (PARTITION BY team_name ORDER BY score DESC) as highest_scoring_emp
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEE_SCORES
WHERE assessment_no = 2 
QUALIFY highest_scoring_emp in (1, 2);

-- CASE, IFF and NULL Handling
CREATE OR REPLACE TABLE movies ( 
    movie_id    NUMBER, 
    movie_name  VARCHAR(100), 
    imdb_rating NUMBER(3, 1), 
    genre       VARCHAR(50) 
); 

INSERT INTO movies VALUES 
    (1, 'Skyward', 8.7, 'Drama'), 
    (2, 'Last Signal', 1.8, 'Science Fiction'), 
    (3, 'City Lights Again', 6.5, 'Comedy'), 
    (4, 'Unknown Route', NULL, 'Thriller'), 
    (5, 'River Song', 4.2, 'Drama'), 
    (6, 'Beyond the Hill', 8.0, 'Adventure'); 

-- Questions
-- 1. Create a rating label using these rules: NULL = Not Rated, above 8 = Excellent, 6 through 8 = Good, 3 through below 6 = Average, and below 3 = Poor. 
SELECT 
    movie_id,
    movie_name,
    CASE 
        WHEN imdb_rating <= 3 THEN 'Poor'
        WHEN imdb_rating > 3 AND imdb_rating <= 6 THEN 'Average'
        WHEN imdb_rating > 6 AND imdb_rating <= 8 THEN 'Good'
        WHEN imdb_rating > 8  THEN 'Excellent'
        ELSE 'Not Rated'
        END AS rating_label
FROM SQL_ASSIGN_DB.PUBLIC.MOVIES;

-- SELECT *
-- FROM SQL_ASSIGN_DB.PUBLIC.MOVIES;

-- 2. Use IFF to classify each movie as Recommended when the rating is at least 7, otherwise Review Required. 
SELECT 
    movie_id,
    movie_name,
    IFF(imdb_rating >= 7, 'Recommended', 'Review Required') as 'Recommendation'
FROM SQL_ASSIGN_DB.PUBLIC.MOVIES;

-- 3. Replace missing ratings with 0 using COALESCE. 
SELECT 
    movie_id,
    movie_name,
    COALESCE(imdb_rating, 0) AS rating_available
FROM SQL_ASSIGN_DB.PUBLIC.MOVIES;

-- 4. Count movies in each rating label. 
SELECT 
    CASE 
        WHEN imdb_rating <= 3 THEN 'Poor'
        WHEN imdb_rating > 3 AND imdb_rating <= 6 THEN 'Average'
        WHEN imdb_rating > 6 AND imdb_rating <= 8 THEN 'Good'
        WHEN imdb_rating > 8  THEN 'Excellent'
        ELSE 'Not Rated'
        END AS rating_label,
    COUNT(rating_label) as no_of_movies
FROM SQL_ASSIGN_DB.PUBLIC.MOVIES
GROUP BY rating_label;

-- 5. Create a genre-specific flag: Drama with rating at least 7 = Priority Drama, all others = Standard. 
SELECT 
    movie_id,
    movie_name,
    CASE 
        WHEN imdb_rating >= 7 THEN 'Priority Drama'
        ELSE 'Standard'
    END AS genre_specific_flag
FROM SQL_ASSIGN_DB.PUBLIC.MOVIES
WHERE genre = 'Drama';

--Challenge question
-- Create a score band using a lookup table instead of CASE. Define and load the lookup table yourself. Display movies with the band.

CREATE TABLE SQL_ASSIGN_DB.PUBLIC.score_bands (
    band_name VARCHAR(50),
    min_score DECIMAL(3,1),
    max_score DECIMAL(3,1)
);

-- Load the band definitions
INSERT INTO SQL_ASSIGN_DB.PUBLIC.SCORE_BANDS (band_name, min_score, max_score) VALUES
('Poor',       0.0, 3.0),
('Average',    3.0, 6.0),
('Good',       6.0, 8.0),
('Excellent', 8.0, 10.0),
('Not Rated', 0.0, 0.0);

SELECT 
    m.movie_id,
    m.movie_name,
    m.imdb_rating,
    b.band_name
FROM SQL_ASSIGN_DB.PUBLIC.MOVIES m
INNER JOIN SQL_ASSIGN_DB.PUBLIC.SCORE_BANDS b
ON m.imdb_rating >= b.min_score AND m.imdb_rating < b.max_score;

-- Subqueries 
CREATE OR REPLACE TABLE products ( 
    product_id   NUMBER, 
    product_name VARCHAR(100), 
    unit_price   NUMBER(10, 2) 
); 
 
CREATE OR REPLACE TABLE orders ( 
    order_id    NUMBER, 
    product_id  NUMBER, 
    quantity    NUMBER, 
    price_paid  NUMBER(10, 2), 
    order_date  DATE 
); 

INSERT INTO products VALUES 
    (101, 'Wireless Mouse', 1200), 
    (102, 'Mechanical Keyboard', 4500), 
    (103, 'HDMI Cable', 400), 
    (104, '4K Monitor', 25000), 
    (105, 'Laptop Stand', 1800); 
 
INSERT INTO orders VALUES 
    (1, 103, 2, 400, '2025-01-10'), 
    (2, 101, 1, 1200, '2025-01-15'), 
    (3, 103, 1, 400, '2025-02-02'), 
    (4, 102, 1, 4200, '2025-02-11'), 
    (5, 101, 2, 1100, '2025-03-05'); 

-- 1. Return products priced above the average unit price of all products. 
SELECT
    product_id, 
    product_name,
    unit_price
FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS
WHERE unit_price > (
        SELECT AVG(unit_price) FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS
);

-- 2. Return products that appear in the orders table (Hint: Use IN). 
SELECT
    product_id, 
    product_name
FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS
WHERE product_id IN (
        SELECT product_id FROM SQL_ASSIGN_DB.PUBLIC.ORDERS
);

-- 3. Return products that have never been ordered (Hint: Use NOT EXISTS). 
SELECT
    product_id, 
    product_name
FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS
WHERE product_id NOT IN (
        SELECT product_id FROM SQL_ASSIGN_DB.PUBLIC.ORDERS
);
-- 4. Return orders whose price paid is above the average price paid. 
SELECT
    order_id
FROM SQL_ASSIGN_DB.PUBLIC.ORDERS
WHERE price_paid > (
        SELECT AVG(price_paid) FROM SQL_ASSIGN_DB.PUBLIC.ORDERS
);

-- 5. Using a correlated subquery, display each product and the number of orders placed for it. 
SELECT
    product_id,
    (SELECT COUNT(order_id) FROM SQL_ASSIGN_DB.PUBLIC.ORDERS O
        WHERE O.PRODUCT_ID = P.PRODUCT_ID) as no_of_orders
FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS P;   

-- select p.product_id, count(o.order_id) as no_of_orders
-- from sql_assign_db.public.products p 
-- left join sql_assign_db.public.orders o
-- on o.product_id = p.product_id
-- group by p.product_id;


-- 6. Return the product or products with the highest unit price. 
SELECT
    product_id,
    unit_price
FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS
WHERE unit_price = (
        SELECT MAX(unit_price) FROM SQL_ASSIGN_DB.PUBLIC.PRODUCTS
);

-- Rewrite the correlated order-count query(5th question) using a LEFT JOIN and compare the readability of both approaches.
select p.product_id, count(o.order_id) as no_of_orders
from sql_assign_db.public.products p 
left join sql_assign_db.public.orders o
on o.product_id = p.product_id
group by p.product_id;

-- PIVOT 
-- table creation
CREATE OR REPLACE TABLE regional_sales ( 
    region_name VARCHAR(50), 
    product_line VARCHAR(50), 
    sales_month VARCHAR(3), 
    revenue NUMBER(12, 2) 
); 

INSERT INTO regional_sales VALUES 
    ('North', 'Hardware', 'JAN', 12000), ('North', 'Hardware', 'FEB', 15000), 
    ('North', 'Software', 'JAN', 18000), ('North', 'Software', 'FEB', 21000), 
    ('South', 'Hardware', 'JAN', 10000), ('South', 'Hardware', 'FEB', 14000), 
    ('South', 'Software', 'JAN', 16000), ('South', 'Software', 'FEB', 19000), 
    ('South', 'Software', 'MAR', 22000); 

-- Questions 

-- 1. Pivot sales_month so JAN, FEB and MAR become columns. Aggregate revenue by region and product line. 
SELECT
    region_name, 
    product_line,
    "'JAN'", "'FEB'", "'MAR'"
FROM (
    SELECT 
        region_name, 
        sales_month, 
        product_line, 
        revenue
    FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
    ) AS src_data
    PIVOT(
        SUM(revenue)
        FOR sales_month IN ('JAN', 'FEB', 'MAR')
    ) AS pivoted_data;

-- 2. Replace missing pivoted values with zero. 
SELECT
    region_name, 
    product_line,
    COALESCE("'JAN'", 0) AS JAN,
    COALESCE("'FEB'", 0) AS FEB,
    COALESCE("'MAR'", 0) AS MAR
FROM (
    SELECT 
        region_name, 
        sales_month, 
        product_line, 
        revenue
    FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
    ) AS src_data
    PIVOT(
        SUM(revenue)
        FOR sales_month IN ('JAN', 'FEB', 'MAR')
    ) AS pivoted_data;
    
-- 3. Create a pivot showing total monthly revenue by region only. 
SELECT
    region_name, 
    "'JAN'", "'FEB'", "'MAR'"
FROM (
    SELECT 
        region_name, 
        sales_month, 
        revenue
    FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
    ) AS src_data
    PIVOT(
        SUM(revenue)
        FOR sales_month IN ('JAN', 'FEB', 'MAR')
    ) AS pivoted_data;
    
-- 4. Validate that the total revenue before and after pivoting is equal. 
SELECT
    region_name, 
    product_line,
    COALESCE(JAN, 0) AS JAN,
    COALESCE(FEB, 0) AS FEB,
    COALESCE(MAR, 0) AS MAR,
    (COALESCE(JAN, 0) + COALESCE(FEB, 0) + COALESCE(MAR, 0)) as total_revenue
FROM (
    SELECT 
        region_name, 
        sales_month, 
        product_line, 
        revenue
    FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
    ) AS src_data
    PIVOT(
        SUM(revenue)
        FOR sales_month IN ('JAN', 'FEB', 'MAR')
    ) AS pivoted_data;

SELECT sum(revenue)
FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
GROUP BY product_line, region_name;

-- 5. Repeat the first question using conditional aggregation with CASE instead of PIVOT. 

SELECT 
    region_name,
    product_line,
    SUM(CASE WHEN sales_month = 'JAN' THEN revenue ELSE 0 END) AS Jan_Revenue,
    SUM(CASE WHEN sales_month = 'FEB' THEN revenue ELSE 0 END) AS Feb_Revenue,
    SUM(CASE WHEN sales_month = 'MAR' THEN revenue ELSE 0 END) AS Mar_Revenue
FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
GROUP BY region_name, product_line;

-- Challenge question: Use Snowflake dynamic PIVOT with ANY and compare its output with the fixed month list. 
SELECT
    region_name, 
    product_line,
    "'JAN'", "'FEB'", "'MAR'"
FROM (
    SELECT 
        region_name, 
        sales_month, 
        product_line, 
        revenue
    FROM SQL_ASSIGN_DB.PUBLIC.REGIONAL_SALES
    ) AS src_data
    PIVOT(
        SUM(revenue)
        FOR sales_month IN (ANY)
    ) AS pivoted_data;

    -- UNPIVOT 
    CREATE OR REPLACE TABLE annual_targets ( 
    employee_id   NUMBER, 
    employee_name VARCHAR(100), 
    jan_target    NUMBER(10, 2), 
    feb_target    NUMBER(10, 2), 
    mar_target    NUMBER(10, 2), 
    apr_target    NUMBER(10, 2) 
);

INSERT INTO annual_targets VALUES 
    (1, 'Aditi', 100, 120, 130, 140), 
    (2, 'Vikram', 90, 110, NULL, 135), 
    (3, 'Neha', 150, 155, 160, 170); 

-- Questions 
-- 1. Unpivot the four target columns into month_name and target_value. 
SELECT employee_id, employee_name, monthly_target, s_target
FROM annual_targets
UNPIVOT (
    monthly_target
    FOR s_target IN (jan_target, feb_target, mar_target, apr_target)
) AS u;

-- 2. Repeat the query using INCLUDE NULLS. 
SELECT employee_id, employee_name, monthly_target, s_target
FROM annual_targets
UNPIVOT INCLUDE NULLS(
    monthly_target
    FOR s_target IN (jan_target, feb_target, mar_target, apr_target)
) AS u;

-- 3. Count how many month rows are produced for each employee with and without INCLUDE NULLS. 
with unpivot_with_nulls as (
    SELECT employee_id, employee_name, monthly_target, s_target
    FROM annual_targets
    UNPIVOT INCLUDE NULLS(
        monthly_target
        FOR s_target IN (jan_target, feb_target, mar_target, apr_target)
    ) AS u
)
select 
    distinct employee_id, 
    COUNT(s_target) OVER (PARTITION BY employee_id) AS month_rows
from unpivot_with_nulls
ORDER BY employee_id;

with unpivot_without_nulls as (
    SELECT employee_id, employee_name, monthly_target, s_target
    FROM annual_targets
    UNPIVOT (
        monthly_target
        FOR s_target IN (jan_target, feb_target, mar_target, apr_target)
    ) AS u
)
select 
    distinct employee_id, 
    COUNT(s_target) OVER (PARTITION BY employee_id) AS month_rows
from unpivot_without_nulls
ORDER BY employee_id;

-- 4. Return the highest target by employee after unpivoting. 
with unpivot_with_nulls as (
    SELECT employee_id, employee_name, monthly_target, s_target
    FROM annual_targets
    UNPIVOT INCLUDE NULLS(
        monthly_target
        FOR s_target IN (jan_target, feb_target, mar_target, apr_target)
    ) AS u
)
select 
    distinct employee_id, employee_name,
    MAX(monthly_target) OVER (PARTITION BY employee_id) AS highest_target
from unpivot_with_nulls
ORDER BY employee_id;

-- 5. Standardize month labels so JAN_TARGET becomes JAN after unpivoting. 
-- SELECT employee_id, employee_name, monthly_target, s_target
-- FROM annual_targets
-- UNPIVOT (
--     monthly_target
--     FOR s_target IN (jan_target AS JAN, feb_target AS FEB, mar_target AS MAR, apr_target AS APR)
-- ) AS u;

-- -- Challenge question: Recreate the original wide format by pivoting the unpivoted result. 
-- with unpivot_with_nulls as (
--     SELECT employee_id, employee_name, monthly_target, s_target
--     FROM annual_targets
--     UNPIVOT INCLUDE NULLS(
--         monthly_target
--         FOR s_target IN (jan_target, feb_target, mar_target, apr_target)
--     ) AS u
-- )
-- select 
--     distinct employee_id, employee_name,
--     MAX(monthly_target) OVER (PARTITION BY employee_id) AS highest_target
-- from unpivot_with_nulls
-- ORDER BY employee_id;

-- SELECT employee_id, employee_name, "'JAN_TARGET'", "'FEB_TARGET'", "'MAR_TARGET'", "'APR_TARGET'"
-- FROM (
--     SELECT employee_id, employee_name, pivot_column, value_column
--     FROM source_table
-- ) AS source
-- PIVOT (
--     AGGREGATE_FUNCTION(value_column)
--     FOR pivot_column IN ([pivot_value_1], [pivot_value_2])
-- ) AS pivot_table;

-- select * from annual_targets;

-- Common Table Expressions 
-- Database setup
CREATE OR REPLACE TABLE departments ( 
    department_id   NUMBER, 
    department_name VARCHAR(50) 
); 
 
CREATE OR REPLACE TABLE employees ( 
    employee_id   NUMBER, 
    employee_name VARCHAR(100), 
    department_id NUMBER, 
    manager_id    NUMBER, 
    salary        NUMBER(10, 2), 
    college_name  VARCHAR(100), 
    joining_date  DATE 
); 

INSERT INTO departments VALUES 
    (10, 'Data & Analytics'), 
    (20, 'Finance'), 
    (30, 'Human Resources'), 
    (40, 'Operations'); 
 
INSERT INTO employees VALUES 
    (101, 'Aarav', 10, NULL, 95000, 'College A', '2025-01-06'), 
    (102, 'Diya', 10, 101, 72000, 'College B', '2025-02-10'), 
    (103, 'Kabir', 10, 101, 72000, 'College A', '2025-03-12'), 
    (104, 'Meera', 20, NULL, 90000, 'College C', '2024-11-18'), 
    (105, 'Ishaan', 20, 104, 61000, 'College B', '2025-04-03'), 
    (106, 'Anaya', 30, NULL, 82000, 'College A', '2024-12-09'), 
    (107, 'Rohan', 30, 106, 58000, 'College C', '2025-05-15'), 
    (108, 'Tara', NULL, 101, 55000, 'College B', '2025-06-02');

-- Questions 

-- 1. Create a CTE that calculates average salary by department. Join it to employees and show the difference from the average. 
WITH deptwise_avg_salary AS (
    SELECT
        department_id,
        round(avg(salary), 2) as avg_salary
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    WHERE department_id IS NOT NULL
    GROUP BY department_id
)
SELECT 
    d.department_id, 
    e.employee_id,
    e.salary,
    d.avg_salary,
    e.salary - d.avg_salary as salary_diff
FROM DEPTWISE_AVG_SALARY d
RIGHT JOIN SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e
ON d.department_id = e.department_id;

-- 2. Create two CTEs: one for employee counts and another for average salary. Combine them into one department summary. 
WITH emp_count AS (
    SELECT
        department_id,
        count(distinct employee_id) as no_of_employees
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    GROUP BY department_id
),
deptwise_avg_salary AS (
    SELECT
        department_id,
        round(avg(salary), 2) as avg_salary
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    GROUP BY department_id
)
SELECT 
    d.department_id, 
    e.no_of_employees,
    d.avg_salary
FROM EMP_COUNT e
LEFT JOIN DEPTWISE_AVG_SALARY d
ON d.department_id = e.department_id
WHERE d.department_id IS NOT NULL;

-- 3. Use a CTE to identify employees who joined in 2025, then summarize them by college. 
WITH emp_2025 AS (
    SELECT
        employee_id,
        college_name,
        YEAR(joining_date) as joining_year
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    WHERE YEAR(joining_date) = 2025
)
SELECT 
    e.employee_id,
    e.college_name
FROM EMP_2025 e
ORDER BY e.college_name;

-- 4. Write a nested subquery that finds above-average earners. Rewrite this query using CTE. 
SELECT employee_id, employee_name
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
WHERE salary > (SELECT AVG(salary)
                FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
                );

WITH avg_salary_cte AS (
    SELECT AVG(salary) as avg_salary
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
)
SELECT e.employee_id
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e
CROSS JOIN avg_salary_cte c
WHERE e.salary > c.avg_salary;

-- 5. Create a CTE that assigns salary bands and then counts employees by band.
WITH salary_band_cte AS (
    SELECT 
        employee_id,
        employee_name,
        salary,
        case
            when salary < 50000 then 1
            when salary < 80000 and salary >= 50000 then 2
            when salary < 90000 and salary >= 80000 then 3
            else 4
        end as salary_bands
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
)
SELECT 
    salary_bands,
    COUNT(distinct employee_id) as no_of_employees
FROM salary_band_cte
GROUP BY salary_bands
ORDER BY salary_bands;

-- Challenge question: Build a three-stage CTE pipeline: clean department values(replacing nulls with ‘NA’), calculate department metrics(no. of employees, avg. salary of dept, highest salary in dept, lowest salary in dept etc. ), and return employees whose salary is above their department average.
WITH clean_nulls AS (
    SELECT 
        employee_id, 
        COALESCE(department_id, 'NA')
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
),
dept_metrics AS (
    SELECT 
        department_id,
        COUNT(distinct employee_id) as no_of_employees,
        avg(salary) as avg_salary,
        max(salary) as max_salary,
        min(salary) as max_salary
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    WHERE department_id IS NOT NULL
    GROUP BY department_id
),
above_avg_emp as (
    SELECT e.employee_id
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e
    LEFT JOIN dept_metrics d
    ON e.department_id = d.department_id
    WHERE e.salary > d.avg_salary
)
select * from above_avg_emp;

-- Recursive CTEs 
-- Dataset Setup 
CREATE OR REPLACE TABLE organisation ( 
    employee_id   NUMBER, 
    employee_name VARCHAR(100), 
    manager_id    NUMBER, 
    job_title     VARCHAR(100) 
); 

INSERT INTO organisation VALUES 
    (1, 'Meera', NULL, 'Director'), 
    (2, 'Aarav', 1, 'Senior Manager'), 
    (3, 'Diya', 2, 'Manager'), 
    (4, 'Kabir', 3, 'Engineer'), 
    (5, 'Tara', 3, 'Engineer'), 
    (6, 'Rohan', 2, 'Manager'), 
    (7, 'Anaya', 6, 'Analyst'); 

-- Questions 

-- 1. Create a recursive CTE that returns all employees with their managers 
-- (Ex: Employee_id:7, Employee_name: Anaya, Manager: Rohan). 
WITH RECURSIVE emp_manager_cte AS (
    SELECT 
        employee_id, 
        employee_name,
        manager_id
    FROM SQL_ASSIGN_DB.PUBLIC.ORGANISATION
    UNION ALL
    SELECT
        c.employee_id,
        c.employee_name,
        m.manager_id
    FROM emp_manager_cte c
    JOIN SQL_ASSIGN_DB.PUBLIC.ORGANISATION m
    ON c.manager_id = m.employee_id
)
SELECT 
    employee_id,
    employee_name,
    manager_name
FROM emp_manager_cte
ORDER BY employee_id;

-- 2. Add a level_number showing the hierarchy level. 
WITH RECURSIVE emp_manager_cte AS (
    SELECT 
        employee_id, 
        employee_name,
        manager_id,
        0 as level
    FROM SQL_ASSIGN_DB.PUBLIC.ORGANISATION
    UNION ALL
    SELECT
        c.employee_id,
        c.employee_name,
        m.manager_id,
        c.level + 1
    FROM emp_manager_cte c
    JOIN SQL_ASSIGN_DB.PUBLIC.ORGANISATION m
    ON c.manager_id = m.employee_id
)
SELECT *
FROM emp_manager_cte
ORDER BY employee_id;

-- 3. Add a hierarchy_path such as Kabir<Diya<Aarav<Meera. 
WITH RECURSIVE emp_manager_cte AS (
    SELECT 
        employee_id, 
        employee_name,
        manager_id,
        employee_name as hierarchy,
        0 as level
    FROM SQL_ASSIGN_DB.PUBLIC.ORGANISATION
    UNION ALL
    SELECT
        c.employee_id,
        c.employee_name,
        m.manager_id,
        CONCAT(c.hierarchy, '->', m.employee_name),
        c.level + 1
    FROM emp_manager_cte c
    JOIN SQL_ASSIGN_DB.PUBLIC.ORGANISATION m
    ON c.manager_id = m.employee_id
)
SELECT *
FROM emp_manager_cte
ORDER BY employee_id;

-- 4. Return all employees reporting directly or indirectly to Aarav. 
WITH RECURSIVE emp_manager_cte AS (
    SELECT 
        employee_id, 
        employee_name,
        manager_id,
        employee_name as hierarchy,
        0 as level
    FROM SQL_ASSIGN_DB.PUBLIC.ORGANISATION
    UNION ALL
    SELECT
        c.employee_id,
        c.employee_name,
        m.manager_id,
        CONCAT(c.hierarchy, '->', m.employee_name),
        c.level + 1
    FROM emp_manager_cte c
    JOIN SQL_ASSIGN_DB.PUBLIC.ORGANISATION m
    ON c.manager_id = m.employee_id
)
SELECT *
FROM emp_manager_cte
WHERE 
ORDER BY employee_id;
-- 5. Return only leaf employees who do not manage anyone.

-- Challenge question: Add a deliberately circular relationship in a separate test table and explain how you would prevent uncontrolled recursion. 

-- Final Integrated Assignment 
CREATE OR REPLACE TABLE departments ( 
    department_id   NUMBER, 
    department_name VARCHAR(50) 
); 
 
CREATE OR REPLACE TABLE employees ( 
    employee_id   NUMBER, 
    employee_name VARCHAR(100), 
    department_id NUMBER, 
    manager_id    NUMBER, 
    salary        NUMBER(10, 2), 
    college_name  VARCHAR(100), 
    joining_date  DATE 
); 

INSERT INTO departments VALUES 
    (10, 'Data & Analytics'), 
    (20, 'Finance'), 
    (30, 'Human Resources'), 
    (40, 'Operations');
 
INSERT INTO employees VALUES 
    (101, 'Aarav', 10, NULL, 95000, 'College A', '2025-01-06'), 
    (102, 'Diya', 10, 101, 72000, 'College B', '2025-02-10'), 
    (103, 'Kabir', 10, 101, 72000, 'College A', '2025-03-12'), 
    (104, 'Meera', 20, NULL, 90000, 'College C', '2024-11-18'), 
    (105, 'Ishaan', 20, 104, 61000, 'College B', '2025-04-03'), 
    (106, 'Anaya', 30, NULL, 82000, 'College A', '2024-12-09'), 
    (107, 'Rohan', 30, 106, 58000, 'College C', '2025-05-15'), 
    (108, 'Tara', NULL, 101, 55000, 'College B', '2025-06-02'); 

-- 1. Display every employee with department name and manager name. 
   WITH emp_with_dept AS ( 
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        d.department_name
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e
    LEFT JOIN SQL_ASSIGN_DB.PUBLIC.DEPARTMENTS d
    ON e.department_id = d.department_id
)
SELECT 
    ed.employee_id,
    ed.employee_name,
    ed.department_name,
    e1.manager_name
FROM emp_with_dept ed
LEFT JOIN SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e1
ON ed.manager_id = e1.employee_id;

-- 2. Calculate department average salary and each employee’s difference from that average. 
WITH deptwise_avg_salary AS (
    SELECT
        department_id,
        round(avg(salary), 2) as avg_salary
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    WHERE department_id IS NOT NULL
    GROUP BY department_id
)
SELECT 
    d.department_id, 
    e.employee_id,
    e.salary,
    d.avg_salary,
    e.salary - d.avg_salary as salary_diff
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e 
LEFT JOIN DEPTWISE_AVG_SALARY d
ON d.department_id = e.department_id;

-- 3. Rank employees by salary within their department. 
SELECT
    department_id,
    employee_id,
    salary,
    RANK() OVER(
        PARTITION BY department_id ORDER BY salary DESC
    ) as rn
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
ORDER BY department_id;

-- 4. Categorize employees as Above Department Average, Equal to Department Average or Below Department Average. 
WITH deptwise_avg AS (
    SELECT 
        department_id,
        ROUND(AVG(salary), 2) as avg_salary
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    WHERE department_id IS NOT NULL
    GROUP BY department_id
)
SELECT 
    e.employee_id,
    CASE 
        WHEN e.salary > d.avg_salary THEN 'Above Department Average'
        WHEN e.salary = d.avg_salary THEN 'Equal to Department Average'
        ELSE 'Below Department Average'
    END AS salary_bands
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES e
LEFT JOIN deptwise_avg d
ON e.department_id = d.department_id;

-- 5. Return only the highest-paid employee or employees in each department. 

SELECT 
    department_id, 
    employee_id,
    salary,
   RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS max_salary_rn
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
QUALIFY max_salary_rn = 1;

-- 6. Use a CTE to organize the final solution. 
WITH max_cte AS (
    SELECT 
        department_id, 
        employee_id,
        salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS max_salary_rn
    FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES
    )
SELECT *
FROM max_cte
WHERE max_salary_rn = 1;

-- 7. Add a data-quality flag for missing department or manager information. 
SELECT  
    employee_id,
    employee_name,
    manager_id,
    department_id,
    CASE 
        WHEN department_id IS NULL THEN 'Missing department_id'
        WHEN manager_id IS NULL THEN 'Missing manager_id'
    END AS data_quality_flag
FROM SQL_ASSIGN_DB.PUBLIC.EMPLOYEES;



