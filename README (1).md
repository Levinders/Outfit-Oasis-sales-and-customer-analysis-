![Outfit-Oasis-banner.png](https://github.com/Levinders/Outfit-Oasis-sales-and-customer-analysis-/blob/main/Outfit%20Oasis%20banner.png)

# Overview

Outfit Oasis is a leading retail store that specializes in three main product categories: Beauty, Electronics, and Clothing. With a strong commitment to customer satisfaction and product quality, the company serves 200+ diverse age groups of customers and has established itself as a trusted name in the retail sector.

This project focuses on analyzing sales and customer data from Outfit Oasis database to draw insights that will drive strategic decisions for marketing and operations in 2025\. By leveraging historical data from 2022 and 2023, the analysis aims to identify key trends, customer behavior patterns, sales performance, and growth opportunities.

# Objectives & Details

### Business Analysis: a descriptive EDA to answer the following business questions   
  * Sales performance  
  * Customer insight  
  * Product performance evaluation  
  * Profitability analysis  
  * Seasonal trends identification  
  * Operational insight  
      
### Tools Used: 
  * SQL  
  * VSCode  
  * Postgres
  * Excel for project status & tracking
     
### Processes Followed:  
  * Derived business/analytical questions from the business request which came from the sales manager - Chloe
  * Feedback from Chloe on the business questions and draft of the business demand overview
  * Established connection to the DB (I got the sales dataset from a repo on GitHub)  
  * Created a table named ‘retail\_sales’ in Outfit Oasis sales DB  
  * Imported sales data into the table  
  * Data cleaning \- identified, removed & updated null, and standardized records  
  * Exploratory data analysis operations to answer business questions. This is the scope of this project

# Project Structure 

### 1. Database
  * **Table Creation:** A table named retail_sales is created to store the sales data. The table has columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount. Sales data was imported from the DB to this table.

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


**2. Which days of the week generate the highest sales revenue?**

```sql

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

```


**3. What are the peak sales hours and shift times?**

```sql
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

```


**4. What are our gross and net revenue for each year?**

```sql
SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        SUM(total_sale) AS gross_sales,
        ROUND(SUM(total_sale) - SUM(cogs)) AS net_sales
FROM retail_sales
GROUP BY ROLLUP(EXTRACT(YEAR FROM sale_date))
ORDER BY year;
```


### Customer Insights
**1. How many unique customers purchased from us?**

```sql

SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        COUNT(DISTINCT customer_id) 
FROM retail_sales 
GROUP BY EXTRACT(YEAR FROM sale_date);

```


**2. What is the gender distribution of customers?**


```sql

SELECT 
        COUNT(DISTINCT customer_id) AS num_of_cust,
        gender
FROM retail_sales 
GROUP BY gender;

```


**3. What is the average age of customers for each category?**

```sql
SELECT 
        category,
        ROUND(AVG(age)) AS avg_customer_age
FROM retail_sales 
GROUP BY category;

```


### Product Performance
**1. Which category has the highest average sales revenue?**

```sql

SELECT
        category,
        ROUND(AVG(total_sale)) AS total_avg_sales
FROM retail_sales 
GROUP BY category
ORDER BY total_avg_sales DESC
LIMIT 1;

```


**2. What is the most frequently purchased category?**  

```sql

SELECT 
        category,
        COUNT(transactions_id) AS total_purchases
FROM retail_sales 
GROUP BY category
ORDER BY total_purchases DESC
LIMIT 1;

```


### Profitability
**1. What is the average profit margin by category (Total Sale - COGS)?**

```sql

    SELECT
            category,
            ROUND(AVG(total_sale - cogs)) AS profit_margin
    FROM retail_sales 
    GROUP BY category;

```


**2. Which category contributes the most to overall profitability?**

```sql

    SELECT 
            category,
            ROUND(SUM(total_sale - cogs)) AS net_profit
    FROM retail_sales
    GROUP BY category
    ORDER BY net_profit DESC
    LIMIT 1;

```


### Seasonal Trends
**1. How do monthly sales trends vary across product categories?**

```sql

SELECT
        category,
        EXTRACT(MONTH FROM sale_date) AS month,
        COUNT(transactions_id) AS total_sales
FROM retail_sales
GROUP BY category, MONTH
ORDER BY MONTH ASC, total_sales DESC;

```


**2. What is the most loyal customer age group by sales?                                                                                

```sql

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

```


**2. Who are the most performing customers?**

```sql
SELECT 
        DISTINCT customer_id AS customers,
        COUNT(transactions_id) AS total_sales,
        SUM(total_sale) AS total_order_amt
FROM retail_sales
GROUP BY customers
ORDER BY total_sales DESC;               

```


### Operational Insights
**1. What is the average order size (quantity) by category?**

```sql
SELECT
        category,
        ROUND(AVG(quantity)) avg_order_qty
FROM retail_sales
GROUP BY category
ORDER BY avg_order_qty DESC;

```


**2. Are there any significant price differences between categories?**

```sql

SELECT
        category,
        price_per_unit
FROM retail_sales
GROUP BY category, price_per_unit
ORDER BY price_per_unit DESC, category;

-- End of the EDA

```


# Highlights of Findings
1. Outfit Oasis is a profitable business as sales revenue is in the range of $310k+ across three categories
2. The most selling category in the store is Clothing. Marketing can focus on upselling other categories in that aisle
3. The first five ever customers of the business are the most loyal out of the 200+ customer base.
4. Afternoon shift and workers do more sales compared to the other shifts 
5. Outfit Oasis has the same proportion of customers by gender


# Conclusion
This analysis provided valuable insights into Outfit Oasis' sales performance, customer insight, product by category trends, and profitability for the 2022-2023 business period. However, data for 2024 was notably absent from the dataset, and this absence likely stems from operational changes within the company.

In December 2024, Outfit Oasis undertook a major migration of its data infrastructure to a more robust system to accommodate growing data needs and enhance analytical capabilities. This transition caused a temporary gap in data collection as sales and customer transactions from 2024 were still in the process of being integrated into the new database at the time of this analysis.

Despite this gap, the comprehensive findings from the available data highlight clear trends and actionable opportunities that can shape operational and marketing strategies for 2025 and beyond.


# Author - Raphael Levinder
This project is part of my stellar portfolio projects, showcasing the SQL skills essential for any data analyst role. If you have any questions, or feedback, or would like to collaborate, feel free to get in touch!

- **[LinkedIn](https://www.linkedin.com/in/raphaellevinder/)**
- **[Email](mailto:raphaellevinder@gamil.com)**
- **[Website](https://gckarchive.com/)**
