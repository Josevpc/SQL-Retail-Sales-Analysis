# Retail Sales Analysis SQL Project

This is the first project of many more i wanna do to improve my habilities and to build an portifolio in data analysis and data science.

At first i was think about how to do those projects because i'm not so creative at this moment. So on youtube i've founded the youtube channel of [Najirh](https://github.com/najirh), [Zero Analyst](https://www.youtube.com/@zero_analyst), with a tone of classes and projects ideas with the execution of the hole projects. So i let here my thanks for [Najirh](https://github.com/najirh) and his rich content.

So the original project has an free retail sales database and 10 business questions to be solved to guide the data analysis, all of this been solved in video. To challenge myself i've include more 10 business questions and improved those questions in Chat GPT to get an more bigger perspect than mine, since i'm starting.

## Overview

**Title**: Retail Sales Analysis
**Level**: Beginner
**Database**: `sql_project_p1`

The main goal of this project is demonstrate SQL skills and techniques used by data analysts to explore, clean, and analyze data using retail sales as cenario. The project involves setting up a retail sales database from .csv to SQL, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project_p1`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount. All the columns have to match names with the data from the .csv to be able to populate the table.

```sql
CREATE DATABASE sql_project_p1;

CREATE TABLE retail_sales
			(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantiy INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT * FROM retail_sales LIMIT 10;
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(*) as total_sale FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR 
	customer_id IS NULL OR gender IS NULL OR age IS NULL OR
	category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR
	cogs IS NULL OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR
	customer_id IS NULL OR gender IS NULL OR age IS NULL OR
	category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR
	cogs IS NULL or total_sale IS NULL;

SELECT COUNT(*) FROM retail_sales;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing' AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11' AND
	quantiy >= 4;
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT 
	category, 
	SUM(total_sale) as net_sale,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
	ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT
	category, gender, COUNT(*) as total_trans
FROM retail_sales
GROUP 
	BY category, gender
ORDER BY 1;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT
	year, month, avg_total_sale
FROM (
	SELECT
		-- This will work only on Postgre
		EXTRACT (YEAR FROM sale_date) as year,
		EXTRACT (MONTH FROM sale_date) as month,
		AVG(total_sale) as avg_total_sale,
		RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG (total_sale) DESC) as rank
	FROM retail_sales
	GROUP BY 1, 2
) as t1
WHERE rank = 1;
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT 
	customer_id, 
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT
	category,
	COUNT(DISTINCT customer_id) as cnt_unique_cs  
FROM retail_sales
GROUP BY 1;
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
WITH hourly_sale
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift;
```
More Bussines questions:

12. **Write a SQL query to find the average total sale (total_sale) by age group (e.g., 18–25, 26–35, 36–45, etc.).**:
13. **Write a SQL query to find the top 3 products with the highest quantity sold (quantiy) in December 2022.**:
14. **Write a SQL query to list all transactions made by female customers (gender = 'Female') who are older than 30.**:
15. **Write a SQL query to find the day of the week with the highest number of sales (based on sale_date).**:
16. **Write a SQL query that returns the total sales (total_sale) and the cost of goods sold (cogs) per customer, and calculates the profit margin (total_sale - cogs) for each one.**:
17. **Write a SQL query to show the average ticket size by category (average ticket = average total_sale per transaction).**:
18. **Write a SQL query to return sales made on the first and last day present in the table (sale_date).**:
19. **Write a SQL query to find the category with the highest price per unit variation (largest difference between MAX(price_per_unit) and MIN(price_per_unit) within the category).**:
20. **Write a SQL query to find the average number of transactions per customer (customer_id).**:

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

### Connect with me on LinkedIn:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/josevpc/)