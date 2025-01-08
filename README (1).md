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

1. Database  
  * **Table Creation:** A table named retail_sales is created to store the sales data. The table has columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount

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
  * 

