![Outfit Oasis Banner](outfit%20oasis%20banner%20%282%29.png)

# Overview

Outfit Oasis is a leading retail store that specializes in three main product categories: Beauty, Electronics, and Clothing. With a strong commitment to customer satisfaction and product quality, the company serves a diverse customer base and has established itself as a trusted name in the retail sector.

This project focuses on analyzing sales and customer data from Outfit Oasis db to uncover insights that will drive strategic decisions for marketing and operations in 2025\. By leveraging historical data from 2022 and 2023, the analysis aims to identify key trends, customer behavior patterns, and opportunities for growth.

# Objectives & Details

* **Business Analysis:** a descriptive EDA to answer the following business questions   
  * Sales performance  
  * Customer insight  
  * Product performance evaluation  
  * Profitability analysis  
  * Seasonal trends identification  
  * Operational insight  
      
* **Tools Used:**  
  * SQL  
  * VSCode  
  * Postgres
  * Excel for project tracking
     
* **Processes Followed:**  
  * I got the sales dataset from a repo on GitHub  
  * Created a table named ‘retail\_sales’ in Outfit Oasis sales db  
  * Imported sales data into the table  
  * Data cleaning \- identified, removed & updated null, and standardized records  
  * Exploratory data analysis operations to answer business questions. This is the scope of this project

# Project Structure 

### 1. Database
  * **Table Creation:** A table named retail_sales is created to store the sales data. The table has columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount. Sales data was imported from the db to this table.

```sql

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

```

### 2. Data Exploration & Cleaning
* **Record:** select all columns and delete all records with empty total_sale which indicates invalid transactions
* **Null:** updated empty age column by gender for valid transactions
* **Data transformation:** changed genders specified as 'M' to 'Male and 'F' to 'Female. Remove space from ' Male'

```sql

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

```


### 3. Exploratory Data Analysis
The following queries were developed to answer the business questions

### Sales Performance
**1. What is the total sales revenue by category?**

```sql

SELECT
        category, 
        SUM(total_sale) AS total_sales
FROM retail_sales 
GROUP BY category;

```


**2**


