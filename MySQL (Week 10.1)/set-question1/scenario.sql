-- Scenario 1: Employee Salary Analysis
-- Question: Find the names and salaries of employees who earn more than the average salary in the company.
-- Step: Calculate average salary using subquery, then filter employees above that value.
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Scenario 2: Customer Orders without Matching Records
-- Question: Retrieve a list of customer names who have not placed any orders.
-- Step: Use LEFT JOIN and filter where order is NULL.

SELECT c.customer_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- Scenario 3: Product Sales Summary
-- Question: Display the total sales amount for each product.
-- Step: Join products and sales, then group by product.

SELECT p.product_name, SUM(s.amount) AS total_sales
FROM products p
JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.product_name;

-- Scenario 4: Department-Wise Employee Count
-- Question: List each department name with the number of employees working in it.
-- Step: Join departments and employees, then count employees per department.

SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
ON d.department_id = e.department_id
GROUP BY d.department_name;

-- Scenario 5: Top 3 Highest Sales
-- Question: Find the top 3 highest sales transactions.
-- Step: Order sales in descending order and limit to top 3.

SELECT *
FROM sales
ORDER BY amount DESC
LIMIT 3;

-- Scenario 6: Calculate Employee Salary Ranks by Department
-- Question: Display each employee’s name, department name, salary, and their salary rank within their respective department.
-- Step: Use window function RANK() partitioned by department.

SELECT
e.employee_name,
d.department_name,
e.salary,
RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;