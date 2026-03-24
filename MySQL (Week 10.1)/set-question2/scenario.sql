-- Scenario 1: Identify Consistent High Performers
-- Question: Find employees who have consistently received a salary increase for the past 3 years.
-- Step: Compare salary records year by year using self-joins or lag function to ensure each year’s salary is greater than the previous year.

SELECT DISTINCT e1.employee_id
FROM employee_salary e1
JOIN employee_salary e2
ON e1.employee_id = e2.employee_id
AND e1.year = e2.year + 1
JOIN employee_salary e3
ON e1.employee_id = e3.employee_id
AND e2.year = e3.year + 1
WHERE e1.salary > e2.salary
AND e2.salary > e3.salary;

-- Scenario 2: Customer Retention Analysis
-- Question: Find customers who made purchases in the last 6 months but not in the previous 6 months.
-- Step: Use date filtering with subqueries or conditional aggregation to separate two time periods.
SELECT customer_id
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
AND customer_id NOT IN (
SELECT customer_id
FROM orders
WHERE order_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
);

-- Scenario 3: Identify Products with Declining Sales
-- Question: Find products whose sales decreased by more than 30% compared to the previous month.
-- Step: Aggregate monthly sales and compare current month with previous month using self-join.

WITH monthly_sales AS (
SELECT product_id, DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(amount) AS total_sales
FROM sales
GROUP BY product_id, DATE_FORMAT(order_date, '%Y-%m')
)
SELECT m1.product_id
FROM monthly_sales m1
JOIN monthly_sales m2
ON m1.product_id = m2.product_id
AND m1.month = DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(m2.month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
WHERE m1.total_sales < m2.total_sales * 0.7;

-- Scenario 4: Calculate Moving Average of Sales
-- Question: Calculate a 3-month moving average for product sales.
-- Step: Use window function AVG() over a rolling 3-month partition.
SELECT
product_id,
order_date,
AVG(amount) OVER (
PARTITION BY product_id
ORDER BY order_date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_avg_3_months
FROM sales;

-- Scenario 5: Detect Duplicate Records
-- Question: Find all duplicate records from a customer table based on email and phone number.
-- Step: Group by email and phone, then filter groups having count > 1.
SELECT email, phone, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email, phone
HAVING COUNT(*) > 1;

-- Scenario 6: Identify Products with No Sales for 3 Consecutive Months
-- Question: List products that have not had any sales for 3 consecutive months.
-- Step: Check missing sales months using grouped monthly data and window functions or gaps detection.
WITH monthly_sales AS (
SELECT product_id, DATE_FORMAT(order_date, '%Y-%m') AS month
FROM sales
GROUP BY product_id, DATE_FORMAT(order_date, '%Y-%m')
), ranked AS (
SELECT product_id, month,
ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY month) AS rn
FROM monthly_sales
)
SELECT DISTINCT r1.product_id
FROM ranked r1
JOIN ranked r2
ON r1.product_id = r2.product_id
AND r1.rn = r2.rn + 2
WHERE
TIMESTAMPDIFF(MONTH, STR_TO_DATE(CONCAT(r1.month, '-01'), '%Y-%m-%d'),
STR_TO_DATE(CONCAT(r2.month, '-01'), '%Y-%m-%d')) = 2;