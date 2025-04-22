-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p1;

-- CREATE TABLE:
DROP TABLE IF EXISTS retail_sales;
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

-- DATA EXPLORATION:

-- Analising if the import was an sucess by looking into the first 10 records
SELECT * FROM retail_sales LIMIT 10;

-- How many records we have ?
SELECT COUNT(*) FROM retail_sales;

-- How many sales we have ?
SELECT COUNT(*) as total_sale FROM retail_sales;

-- How many unique costumers we have ?
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;

-- How many unique category we have ?
SELECT DISTINCT category FROM retail_sales;

-- Verifing with we have NULL values.

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR 
	customer_id IS NULL OR gender IS NULL OR age IS NULL OR
	category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR
	cogs IS NULL OR total_sale IS NULL;

-- DATA CLEANING:

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR sale_date IS NULL OR sale_time IS NULL OR
	customer_id IS NULL OR gender IS NULL OR age IS NULL OR
	category IS NULL OR quantiy IS NULL OR price_per_unit IS NULL OR
	cogs IS NULL or total_sale IS NULL;

-- How many records we have after the cleaning ?
SELECT COUNT(*) FROM retail_sales;

-- Data Analysis & Business Key Problems & Answers

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing' AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11' AND
	quantiy >= 4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
	category, 
	SUM(total_sale) as net_sale,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT
	ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT
	category, gender, COUNT(*) as total_trans
FROM retail_sales
GROUP 
	BY category, gender
ORDER BY 1;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT
	year, month, avg_total_sale
FROM (
	SELECT
		-- just works on Postgres
		EXTRACT (YEAR FROM sale_date) as year,
		EXTRACT (MONTH FROM sale_date) as month,
		AVG(total_sale) as avg_total_sale,
		RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG (total_sale) DESC) as rank
	FROM retail_sales
	GROUP BY 1, 2
) as t1
WHERE rank = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT 
	customer_id, 
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT
	category,
	COUNT(DISTINCT customer_id) as cnt_unique_cs  
FROM retail_sales
GROUP BY 1;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
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

-- More 10 Bussines Questions:

-- Q.11 Write a SQL query to find the average total sale (total_sale) by age group (e.g., 18–25, 26–35, 36–45, etc.).

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

-- Q.12 Write a SQL query to find the category with the highest quantity sold (quantiy) in December 2022.

SELECT 
	category,
	SUM(quantiy)
FROM retail_sales
WHERE TO_CHAR(sale_date, 'YYYY-MM') = '2022-12'
GROUP BY category
ORDER BY 2 DESC
LIMIT 1;


-- Q.13 Write a SQL query to list all transactions made by female customers (gender = 'Female') who are older than 30.

SELECT *
FROM retail_sales
WHERE gender = 'Female' AND age > 30;
	
-- Q.14 Write a SQL query to find the day of the week with the highest number of sales (based on sale_date).

SELECT
	TO_CHAR(sale_date, 'DAY') as day_of_week,
	COUNT(*) as number_of_sales
FROM retail_sales
GROUP BY day_of_week
ORDER BY 2 DESC
LIMIT 1;

-- Q.15 Write a SQL query that returns the total sales (total_sale) and the cost of goods sold (cogs) per customer, and calculates the profit margin (total_sale - cogs) for each one.

SELECT
	customer_id,
	SUM(total_sale) client_total_sale,
	SUM(cogs) AS client_cogs,
	SUM(total_sale - cogs) AS profit_margin
FROM retail_sales
GROUP BY customer_id;

-- Q.16 Write a SQL query to show the average ticket size by category (average ticket = average total_sale per transaction).

SELECT
	category,
	AVG(total_sale) AS average_ticket
FROM retail_sales
GROUP BY category;

-- Q.17 Write a SQL query to return sales made on the first and last day present in the table (sale_date).

SELECT * 
FROM retail_sales
WHERE
	-- Using Subquery
	sale_date = (SELECT MIN (sale_date) FROM retail_sales) OR
	sale_date = (SELECT MAX (sale_date) FROM retail_sales)
ORDER BY sale_date, sale_time DESC;

-- Q.18 Write a SQL query to show the difference between the actual total paid (total_sale) and the price that would have been paid if each unit was sold at the lowest price_per_unit in its category.

	-- Using CTE (Common Table Expression)
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

-- Q.19 Write a SQL query to find the category with the highest price per unit variation (largest difference between MAX(price_per_unit) and MIN(price_per_unit) within the category).

SELECT
	category,
	MAX(price_per_unit) - MIN(price_per_unit) AS price_per_unit_variation
FROM retail_sales
GROUP BY category
ORDER BY 2 DESC;

-- Q.20 Write a SQL query to find the average number of transactions per customer (customer_id).
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

-- End of Project