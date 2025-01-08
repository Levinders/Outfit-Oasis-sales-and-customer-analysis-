-- Active: 1735990625887@@127.0.0.1@5432@outfit_oasis_sales@public

-- Prepping data for analysis
    
    -- Create retail sales table
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales
    (
        transactions_id	INT PRIMARY KEY,
        sale_date DATE,
        sale_time TIME,
        customer_id	INT,
        gender VARCHAR(10),
        age INT,
        category VARCHAR(15),
        quantiy	INT,
        price_per_unit FLOAT,
        cogs FLOAT,
        total_sale	FLOAT	
    );

ALTER TABLE retail_sales 
RENAME COLUMN quantiy TO quantity;

SELECT * FROM retail_sales;  -- Check table creation & correct column names

-- Import sales data from Outfit Oasis database
    -- Since i used Postgres Server AKA my local machine as my server, I already loaded the data
    -- Explore data structure, type and column records to identity inconsistencies

SELECT * FROM retail_sales;  -- Check data importation

-- Cleaning of data (remove nulls, formatting & standardize data)
SELECT * FROM retail_sales
WHERE
        transactions_id IS NULL
    OR  sale_date IS NULL
    OR  sale_time IS NULL
    OR  customer_id IS NULL
    OR  gender IS NULL
    OR  age IS NULL
    OR  category IS NULL
    OR  quantity IS NULL
    OR  price_per_unit IS NULL
    OR  cogs IS NULL
    OR  total_sale IS NULL
ORDER BY 
        total_sale;

    -- 3 out of 13 transactions have empty total_sales which indicates invalid orders. Remove this records
DELETE FROM retail_sales WHERE total_sale IS NULL;

    -- Remaining 10 transactions are valid orders where customers didn't input their age. Update random ages
UPDATE retail_sales
SET age = 
        CASE 
            WHEN gender = 'Female' THEN 40
            WHEN gender = 'Male' THEN 20
        END
        WHERE age IS NULL;

    --Standardize gender column. Update all 'F' to Female and 'M' to Male. Remove spaces for male gender
UPDATE retail_sales
SET gender = 
        CASE 
            WHEN gender = 'M' THEN 'Male'
            WHEN gender = 'F' THEN 'Female'
            WHEN gender NOT LIKE '%Female%' THEN TRIM(gender) 
        END
        WHERE gender IN ('M', 'F') OR gender NOT LIKE '%Female%';


-- Exploratory data analysis (EDA) - Solving business questions

-- Sales performance
    -- 1. What is the total sales revenue by category? 
SELECT
        category, 
        SUM(total_sale) AS total_sales
FROM retail_sales 
GROUP BY category;

    -- 2. Which days of the week generate the highest sales revenue?
SELECT 
        CASE 
            WHEN EXTRACT(dow FROM sale_date) = 0 THEN 'Monday' 
            WHEN EXTRACT(dow FROM sale_date) = 1 THEN 'Tuesday'
            WHEN EXTRACT(dow FROM sale_date) = 2 THEN 'Wednesday'
            WHEN EXTRACT(dow FROM sale_date) = 3 THEN 'Thursday'
            WHEN EXTRACT(dow FROM sale_date) = 4 THEN 'Friday'
            WHEN EXTRACT(dow FROM sale_date) = 5 THEN 'Saturday'
            WHEN EXTRACT(dow FROM sale_date) = 6 THEN 'Sunday'
        END "days_of_the_week",
        SUM(total_sale) AS total_sale_revenue,
        SUM(quantity) AS total_qty_sold
FROM retail_sales 
GROUP BY days_of_the_week ORDER BY total_sale_revenue DESC;

    -- 3. What are the peak sales hours and shift times?
SELECT 
        COUNT(transactions_id) AS total_sales, 
        gender,
        CASE 
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN  'Morning shift'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 19 THEN  'Afternoon shift'
            ELSE 'Night shift'
        END AS shift 
FROM retail_sales
GROUP BY ROLLUP(shift, gender)
ORDER BY COUNT(transactions_id) DESC, shift DESC;
 
    -- 4. What are our gross and net revenue for each year?
SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        SUM(total_sale) AS gross_sales,
        ROUND(SUM(total_sale) - SUM(cogs)) AS net_sales
FROM retail_sales
GROUP BY ROLLUP(EXTRACT(YEAR FROM sale_date))
ORDER BY year;
 
--Customer Insights
    -- 1. How many unique customers purchased from us?
SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        COUNT(DISTINCT customer_id) 
FROM retail_sales 
GROUP BY EXTRACT(YEAR FROM sale_date);

    --2. What is the gender distribution of customers?
SELECT 
        COUNT(DISTINCT customer_id) AS num_of_cust,
        gender
FROM retail_sales 
GROUP BY gender;

    -- 3. What is the average age of customers for each category?
SELECT 
        category,
        ROUND(AVG(age)) AS avg_customer_age
FROM retail_sales 
GROUP BY category;

-- Product Performance
    --1. Which category has the highest average sales revenue?
SELECT
        category,
        ROUND(AVG(total_sale)) AS total_avg_sales
FROM retail_sales 
GROUP BY category
ORDER BY total_avg_sales DESC
LIMIT 1;

    -- 2. What is the most frequently purchased category?  
SELECT 
        category,
        COUNT(transactions_id) AS total_purchases
FROM retail_sales 
GROUP BY category
ORDER BY total_purchases DESC
LIMIT 1;

--Profitability
    -- 1. What is the average profit margin by category (Total Sale - COGS)?
    SELECT
            category,
            ROUND(AVG(total_sale - cogs)) AS profit_margin
    FROM retail_sales 
    GROUP BY category;

    -- 2. Which category contributes the most to overall profitability?
    SELECT 
            category,
            ROUND(SUM(total_sale - cogs)) AS net_profit
    FROM retail_sales
    GROUP BY category
    ORDER BY net_profit DESC
    LIMIT 1;

--Seasonal Trends
    --1. How do monthly sales trends vary across product categories?
SELECT
        category,
        EXTRACT(MONTH FROM sale_date) AS month,
        COUNT(transactions_id) AS total_sales
FROM retail_sales
GROUP BY category, MONTH
ORDER BY MONTH ASC, total_sales DESC;

-- 2. What is the most loyal customer age group by  sales?                                                                                            3. Who're the top 5 best performing customer?
SELECT
    CASE 
        WHEN age < 39 THEN 'Younger (below 39)'  
        WHEN age BETWEEN 40 AND 59 THEN 'Middle aged (40 - 59)'
        ELSE 'Older (above 60)'  
    END AS cust_age_group,
    COUNT(transactions_id) AS total_sales
FROM retail_sales
GROUP BY cust_age_group
ORDER by total_sales DESC;

-- 2. Who are the most performing customers?
SELECT 
        DISTINCT customer_id AS customers,
        COUNT(transactions_id) AS total_sales,
        SUM(total_sale) AS total_order_amt
FROM retail_sales
GROUP BY customers
ORDER BY total_sales DESC;               

--Operational Insights

    -- 1. What is the average order size (quantity) by category?
SELECT
        category,
        ROUND(AVG(quantity)) avg_order_qty
FROM retail_sales
GROUP BY category
ORDER BY avg_order_qty DESC;

    -- 2. Are there any significant price differences between categories?
SELECT
        category,
        price_per_unit
FROM retail_sales
GROUP BY category, price_per_unit
ORDER BY price_per_unit DESC, category;

-- End of the EDA
