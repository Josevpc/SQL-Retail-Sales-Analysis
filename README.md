# Retail Sales Analysis SQL Project

This is the first of many projects I want to do to improve my skills and build a portfolio in data analysis and data science.

At first, I wasn’t sure how to approach these projects because I’m not feeling very creative at the moment. While browsing YouTube, I came across the [Zero Analyst](https://www.youtube.com/@zero_analyst) channel by [Najirh](https://github.com/najirh), which features a lot of class-style content and project ideas, along with full project walkthroughs. So I’d like to take a moment to thank Najirh for the valuable content he shares.

The original project uses a free retail sales database and includes 10 business questions that guide the data analysis, all of which are solved in the video. To challenge myself, I added 10 more business questions and refined the original ones using ChatGPT to gain a broader perspective, since I’m just starting out.

## Overview

**Title**: Retail Sales Analysis
**Level**: Beginner
**Database**: `sql_project_p1`

The main goal of this project is to demonstrate SQL skills and techniques commonly used by data analysts to explore, clean, and analyze data, using a retail sales scenario. The project involves setting up a retail sales database by importing CSV files into a PostgreSQL database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries.

I'm also using tools such as Excel, PostgreSQL, Git, and GitHub to manage, analyze, and version-control the project effectively.

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

11. **Write a SQL query to find the average total sale (total_sale) by age group (e.g., 18–25, 26–35, 36–45, etc.).**:

```sql
SELECT
	CASE
		WHEN age < 18 THEN 'Teenager'
		WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
		WHEN age BETWEEN 36 AND 60 THEN 'Adult'
		ELSE 'Senior'
	END AS age_group,
	AVG(total_sale) AS avg_total_sale
FROM retail_sales
GROUP BY 1;
```

12. **Write a SQL query to find the category with the highest quantity sold (quantiy) in December 2022.**:

```sql
SELECT 
	category,
	SUM(quantiy)
FROM retail_sales
WHERE TO_CHAR(sale_date, 'YYYY-MM') = '2022-12'
GROUP BY category
ORDER BY 2 DESC
LIMIT 1;
```

13. **Write a SQL query to list all transactions made by female customers (gender = 'Female') who are older than 30.**:

```sql
SELECT *
FROM retail_sales
WHERE gender = 'Female' AND age > 30;
```

14. **Write a SQL query to find the day of the week with the highest number of sales (based on sale_date).**:

```sql
SELECT
	TO_CHAR(sale_date, 'DAY') as day_of_week,
	COUNT(*) as number_of_sales
FROM retail_sales
GROUP BY day_of_week
ORDER BY 2 DESC
LIMIT 1;
```

15. **Write a SQL query that returns the total sales (total_sale) and the cost of goods sold (cogs) per customer, and calculates the profit margin (total_sale - cogs) for each one.**:

```sql
SELECT
	customer_id,
	SUM(total_sale) client_total_sale,
	SUM(cogs) AS client_cogs,
	SUM(total_sale - cogs) AS profit_margin
FROM retail_sales
GROUP BY customer_id;
```

16. **Write a SQL query to show the average ticket size by category (average ticket = average total_sale per transaction).**:

```sql
SELECT
	category,
	AVG(total_sale) AS average_ticket
FROM retail_sales
GROUP BY category;
```

17. **Write a SQL query to return sales made on the first and last day present in the table (sale_date).**:

```sql
SELECT * 
FROM retail_sales
WHERE
	sale_date = (SELECT MIN (sale_date) FROM retail_sales) OR
	sale_date = (SELECT MAX (sale_date) FROM retail_sales)
ORDER BY sale_date, sale_time DESC;
```

18. **Write a SQL query to show the difference between the actual total paid (total_sale) and the price that would have been paid if each unit was sold at the lowest price_per_unit in its category.**:

```sql
WITH sales_summary AS (
SELECT
	category,
	SUM(total_sale) AS actual_total_sale,
	MIN (price_per_unit) * SUM(quantiy) AS total_sale_as_lowest
FROM retail_sales
GROUP BY category
)
SELECT
	category,
	actual_total_sale,
	total_sale_as_lowest,
	actual_total_sale - total_sale_as_lowest AS difference
FROM sales_summary;
```

19. **Write a SQL query to find the category with the highest price per unit variation (largest difference between MAX(price_per_unit) and MIN(price_per_unit) within the category).**:

```sql
SELECT
	category,
	MAX(price_per_unit) - MIN(price_per_unit) AS price_per_unit_variation
FROM retail_sales
GROUP BY category
ORDER BY 2 DESC;
```

20. **Write a SQL query to find the average number of transactions per customer (customer_id).**:

```sql
WITH transactions_summary AS (
SELECT
	customer_id,
	COUNT(transactions_id) AS customer_transactions
FROM retail_sales
GROUP BY customer_id
)
SELECT
	ROUND(AVG(customer_transactions))
FROM transactions_summary;
```

## Findings & Reports

- **Number of Registers**: The dataset contains 1,987 retail sales records.
- **Customer Demographics**: Customers are distributed across a wide range of age groups. The "Young Adults" group (ages 18–35) accounts for the highest average number of purchases. Seniors are the least active group, and no transactions were recorded for teenagers (under 18). Notably, 735 transactions were made by females over the age of 30.
- **High-Value Transactions**: Multiple transactions exceed 1,000 in total sale value, indicating a presence of premium or bulk purchases in the dataset.
- **Sales Trends**: A month-by-month analysis highlights seasonal sales trends. For instance, July had the highest number of sales in 2022, while February led in 2023, possibly linked to local holidays or promotions.
- **Top Customers**: The analysis revealed the top 5 spending customers, with the highest-spending customer reaching a total of 38,440 in purchases.
- **Category Performance**: The Electronics category generated the highest total revenue, while Clothing had the largest number of individual transactions, suggesting lower-priced or more frequently purchased items.
- **Category Demographics**: The average age of buyers in the Beauty category is 40 years. Beauty also had 141 unique customers, ranking third in popularity behind Electronics and Clothing.
- **Gender and Category Preferences**: Females purchase more from the Beauty category than males, reinforcing typical retail patterns. On the other hand, males slightly outpaced females in Electronics and Clothing purchases, though female participation in those categories remained significant.
- **Sales by Time of Day**: The Evening shift saw the highest number of transactions, followed by Morning with about half as many. This suggests that customers tend to shop outside typical working hours, possibly before or after their jobs.
- **Sales by Weekday**: Sunday recorded the highest number of sales, indicating increased consumer activity during weekends.
- **Sales by Quantity**: In terms of units sold, the Electronics category outperformed all others, pointing to both popularity and potentially high-volume purchases.
- **Profitability**: Overall, the profit margin per customer (total sales - COGS) is healthy, suggesting a sustainable pricing strategy across most categories.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

### Connect with me on LinkedIn:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/josevpc/)