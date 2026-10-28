USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;


-- 1. Write a query to display all columns and rows from the SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER table. 
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- 2. Retrieve the customer key, customer name, account balance, and market segment from the CUSTOMER table. 
select C_CUSTKEY, 
       C_NAME, 
       C_ACCTBAL, 
       C_MKTSEGMENT 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- 3. Display the first 20 customers from the CUSTOMER table. 
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
LIMIT 20;

-- 4. Find all customers whose market segment is 'BUILDING'. 
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
where C_MKTSEGMENT = "BUILDING";

-- 5. Find all customers whose account balance is greater than 5000.
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
where C_ACCTBAL > 5000
order by C_ACCTBAL;

-- 6.	Find customers whose account balance is between 1000 and 5000.
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
where C_ACCTBAL < 5000 and C_ACCTBAL > 1000
order by C_ACCTBAL;

-- 7.	Find customers who belong to either the 'AUTOMOBILE' or 'BUILDING' market segment.
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
where C_MKTSEGMENT = 'AUTOMOBILE' or C_MKTSEGMENT = 'BUILDING';

-- 8.	Find customers whose name starts with the letter 'A'.
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
where C_NAME like 'A%';

-- 9.	Find all orders placed in the year 1995.
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
where year(O_ORDERDATE) = '1995';

-- 10.	Retrieve the top 10 most expensive parts based on P_RETAILPRICE.
select * 
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
order by P_RETAILPRICE desc
limit 10;

-- 11.	Find the total number of customers in the CUSTOMER table.
select count(distinct c_custkey) as total_number_of_customers
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- 12.	Find the minimum, maximum, and average account balance of customers.
select  min(C_ACCTBAL) as min_customer_acc_bal,
        max(C_ACCTBAL) as max_customer_acc_bal,
        avg(C_ACCTBAL) as avg_customer_acc_bal,
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- 13.	Find the total account balance across all customers.
select  sum(C_ACCTBAL) as total_customer_acc_bal
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- 14.	Find the number of customers in each market segment.
select  C_MKTSEGMENT, count(distinct c_custkey) as total_customers
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
group by C_MKTSEGMENT;

-- 15.	Calculate the average account balance for each market segment.
select  C_MKTSEGMENT, avg(C_ACCTBAL) as AVG_ACC_BAL
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
group by C_MKTSEGMENT;

-- 16.	Find market segments having more than 30,000 customers.
select  C_MKTSEGMENT, count(distinct c_custkey) as total_customers
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
group by C_MKTSEGMENT
having count(distinct c_custkey) > 30000;

-- 17.	Using the ORDERS table, find the number of orders for each order status.
select O_ORDERSTATUS, count(O_ORDERKEY) as total_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
group by O_ORDERSTATUS;

-- 18.	Calculate the total gross revenue from the LINEITEM table using:L_EXTENDEDPRICE * (1 - L_DISCOUNT)
select round(sum(L_EXTENDEDPRICE * (1 - L_DISCOUNT)), 0) as total_gross_revenue
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM;

-- 19.	List customer names along with their corresponding nation names by joining CUSTOMER and NATION.c
select C.C_NAME, N.N_NAME
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on C.C_NATIONKEY = N.N_NATIONKEY;

-- 20.	List supplier names along with their corresponding nation names by joining SUPPLIER and NATION
select S.S_NAME, N.N_NAME
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER S
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on S.S_NATIONKEY = N.N_NATIONKEY;

-- 21.	Retrieve order IDs, order dates, total prices, and customer names by joining ORDERS and CUSTOMER.
select O.O_ORDERKEY, O.O_ORDERDATE, O.O_TOTALPRICE, C.C_NAME
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY;

-- 22.	Find the total number of orders placed by each customer.
select C.C_NAME, count(O.O_ORDERKEY) as total_number_of_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
group by C.C_NAME;

-- 23.	Find the top 10 customers who have placed the most orders.
select C.C_NAME, count(O.O_ORDERKEY) as total_number_of_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
group by C.C_NAME
order by count(O.O_ORDERKEY) desc
limit 10;

-- 24.	Find customers who have never placed an order.
select C.C_NAME, count(O.O_ORDERKEY) as total_number_of_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
group by C.C_NAME
having count(O.O_ORDERKEY) = 0;

-- 25.	Display each customer along with the total value of all orders they have placed.
select C.C_NAME, sum(O.O_TOTALPRICE) as total_value
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
group by C.C_NAME
order by C.C_NAME;

-- 26.	Find the top 5 customers based on their cumulative order value.
select C.C_NAME, sum(O.O_TOTALPRICE) as total_value
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
group by C.C_NAME
order by sum(O.O_TOTALPRICE) desc
limit 5;

-- 27.	Join LINEITEM and PART to display the part name, quantity ordered, and extended price.
select P.P_NAME, L.L_QUANTITY, L.L_EXTENDEDPRICE
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
on L.L_PARTKEY = P.P_PARTKEY;

-- 28.	Join SUPPLIER, PARTSUPP, and PART to display supplier name, part name, and available quantity.
select S.S_NAME, P.P_NAME, PS.PS_AVAILQTY
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER S
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PARTSUPP PS
on S.S_SUPPKEY = PS.PS_SUPPKEY
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
on PS.PS_PARTKEY = P.P_PARTKEY;

-- 29.	Find the number of suppliers in each nation by joining SUPPLIER and NATION.
select N.N_NAME, count(distinct S.S_SUPPKEY) as no_of_suppliers
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER S
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on S.S_NATIONKEY = N.N_NATIONKEY
group by N.N_NAME
order by count(distinct S.S_SUPPKEY) desc;

-- 30.	Join REGION and NATION to display each region along with the number of nations belonging to it.
select R.R_NAME, count(distinct N.N_NATIONKEY) as no_of_nations
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION R
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on R.R_REGIONKEY = N.N_REGIONKEY
group by R.R_NAME;

-- 31.	Find parts whose retail price is greater than the overall average retail price of all parts.
select P_NAME, P_RETAILPRICE
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
where P_RETAILPRICE > 
    (select avg(P_RETAILPRICE) as AVG_RETAIL_PRICE
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
    );

-- 32.	Find orders whose total price is greater than the overall average order total price.
select O_ORDERKEY, O_TOTALPRICE
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
where O_TOTALPRICE > 
    (select avg(O_TOTALPRICE) as AVG_ORDER_PRICE
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
    );

-- 33.	Find the second-highest retail price in the PART table.
select P_NAME, P_RETAILPRICE
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART
order by P_RETAILPRICE desc
limit 1
offset 1;

-- 34.	Find customers who have placed at least one order with a total price greater than 400,000.
select C.C_NAME, count(distinct O_ORDERKEY) as no_of_orders_above_40000
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
where O_TOTALPRICE > 400000
group by C.C_NAME;

-- 35.	Find parts that have never been ordered using a LEFT JOIN or NOT IN subquery.
select P.P_PARTKEY, P.P_NAME
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.PART P
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM  L
on P.P_PARTKEY = L.L_PARTKEY
where L.L_ORDERKEY is null;

-- 36.	Use a CTE to find all orders placed by customers belonging to the 'BUILDING' market segment.
select C.C_CUSTKEY, C.C_CUSTNAME, O.O_ORDERKEY
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
where C.C_MKTSEGMENT = 'BUILDING'
order by C.C_CUSTKEY;

-- 37.	Use a CTE to calculate total sales for each supplier and return suppliers whose sales exceed 1,000,000.
with total_sales_per_supplier as (
    select S.S_SUPPKEY, round(sum(L.L_QUANTITY * L.L_EXTENDEDPRICE * (1.00 - L.L_DISCOUNT)), 2) as total_sales
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER S
    left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
    on S.S_SUPPKEY = L.L_SUPPKEY
    group by S.S_SUPPKEY
)
select s_suppkey, total_sales
from total_sales_per_supplier
where total_sales > 1000000;

-- 38.	Find the supplier with the maximum account balance in each nation using a subquery or CTE.
with supplierwise_acc_bal as (
    select S.S_SUPPKEY, 
           S.S_NATIONKEY, 
           S.S_ACCTBAL,
        row_number() over (
            partition by N.N_NATIONKEY
            order by S.S_ACCTBAL desc
        ) as rn
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.SUPPLIER S
    join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
    on S.S_NATIONKEY = N.N_NATIONKEY
)
select S_NATIONKEY, S_SUPPKEY, S_ACCTBAL as max_acc_bal
from supplierwise_acc_bal
where rn = 1
order by S_NATIONKEY;

-- 39.	Find the total number of orders placed by customers from each nation.
select C.C_NATIONKEY, count(distinct O.O_ORDERKEY) as total_no_of_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
on O.O_CUSTKEY = C.C_CUSTKEY
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on C.C_NATIONKEY = N.N_NATIONKEY
group by C.C_NATIONKEY
order by C.C_NATIONKEY;

-- 40.	Find the top 5 nations based on total sales generated from customer orders.
select C.C_NATIONKEY, sum(O.O_TOTALPRICE) as total_no_of_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
on O.O_CUSTKEY = C.C_CUSTKEY
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on C.C_NATIONKEY = N.N_NATIONKEY
group by C.C_NATIONKEY
order by C.C_NATIONKEY desc
limit 5;

-- 41.	Use ROW_NUMBER() to rank customers by account balance within each nation.
select C.C_NATIONKEY,
       C.C_ACCTBAL,
        row_number() over (
            partition by N.N_NATIONKEY
            order by C.C_ACCTBAL desc
        ) as rn
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
on C.C_NATIONKEY = N.N_NATIONKEY
order by C.C_NATIONKEY;


-- 42.	Use RANK() to rank line items by extended price within each order.
select 
       O.O_ORDERKEY,
       L.L_EXTENDEDPRICE,
        row_number() over (
            partition by O.O_ORDERKEY
            order by L.L_EXTENDEDPRICE desc
        ) as rn
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
on O.O_ORDERKEY = L.L_ORDERKEY
order by O.O_ORDERKEY;

-- 43.	Calculate a running total of order prices ordered by O_ORDERDATE using a window function.
SELECT
    O_ORDERDATE,
    O_TOTALPRICE,
    SUM(O_TOTALPRICE) OVER (
        ORDER BY O_ORDERDATE, O_ORDERKEY
    ) AS running_total_price
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
ORDER BY O_ORDERDATE;

-- 44.	Use LAG() to compare each customer's order value with their immediately preceding order value.
SELECT
    C.C_CUSTKEY,
    O.O_ORDERDATE,
    O.O_TOTALPRICE,
    LAG(O.O_TOTALPRICE) OVER (
        PARTITION BY C.C_CUSTKEY
        ORDER BY O_ORDERDATE
    ) AS lagged_total_price
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
ORDER BY C_CUSTKEY;

-- 45.	For each customer, calculate their total order value and assign a rank based on that value using a window function.
SELECT
    C.C_CUSTKEY,
    O.O_TOTALPRICE,
    RANK() OVER(partition by C.C_CUSTKEY order by O.O_TOTALPRICE) AS rank_no
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
on C.C_CUSTKEY = O.O_CUSTKEY
ORDER BY C_CUSTKEY;

-- 46.	Use Snowflake's QUALIFY clause to return only the highest-quantity line item for each order.
select 
       O.O_ORDERKEY,
       L.L_PARTKEY,
       L.L_QUANTITY,
        row_number() over (
            partition by O.O_ORDERKEY
            order by L.L_QUANTITY desc
        ) as rn
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS O
join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM L
on O.O_ORDERKEY = L.L_ORDERKEY
qualify rn = 1
order by O.O_ORDERKEY;

-- 47.	Use Snowflake's IFF() function to classify orders as 'High Value' when O_TOTALPRICE > 150000, otherwise classify them as 'Standard'.
select O_ORDERKEY,   
        IFF(O_TOTALPRICE > 150000, 'High Value', 'Standard')
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS;

-- 48.	Use Snowflake's YEAR() function to extract the order year and calculate the number of orders for each year.
select YEAR(O_ORDERDATE), count(distinct O_ORDERKEY) as total_no_of_orders
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
group by YEAR(O_ORDERDATE)
order by YEAR(O_ORDERDATE);

-- 49.	Use Snowflake's DATEADD() function to identify orders placed within the final 30 days of the dataset's timeline.
select O_ORDERKEY, O_ORDERDATE
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
where O_ORDERDATE >= DATEADD(day, -30, (SELECT MAX(O_ORDERDATE) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS));

