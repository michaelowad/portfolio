/*
Customers and products analysis

Skills used: Joins, CTE's, aggregate functions, views, sub queries

*/

-- Total number of products

SELECT COUNT(*) 
FROM products;

-- Total number of customers

SELECT COUNT(*) 
FROM customers;

-- Total number of purchasing customers

SELECT COUNT(DISTINCT customerNumber)
FROM orders;

-- Non-purchasing customers

SELECT customerNumber, customerName
FROM customers
WHERE NOT EXISTS (SELECT customerNumber
		  FROM orders
		  WHERE customers.customerNumber = orders.customerNumber);


-- Customers with special requests/complaints

SELECT orderNumber, customerName, comments
FROM orders
JOIN customers
ON orders.customerNumber = customers.customerNumber
WHERE comments IS NOT NULL;


-- Top 10 high performing products

SELECT productName, productLine, SUM(quantityOrdered * priceEach)  as revenue
FROM products
JOIN orderdetails
ON products.productCode = orderdetails.productCode
GROUP BY productName
ORDER BY revenue DESC
LIMIT 10;

-- Low performing products (bottom 10)

SELECT productName, productLine, SUM(quantityOrdered * priceEach)  as revenue
FROM products
JOIN orderdetails
ON products.productCode = orderdetails.productCode
GROUP BY productName
ORDER BY revenue
LIMIT 10;

-- Calculate low stock using subquery

SELECT productCode, SUM(quantityOrdered) /(SELECT quantityInStock
					   FROM products
					   WHERE orderdetails.productCode = products.productCode) AS lowStock
FROM orderdetails
GROUP BY productCode
ORDER BY lowStock DESC
LIMIT 10;

SELECT productCode, SUM(quantityOrdered * priceEach) AS totalSales
FROM orderdetails
GROUP BY productCode
ORDER BY totalSales DESC;

-- Show restocking priority using CTE

WITH restockPriority AS (
SELECT productCode, SUM(quantityOrdered) /(SELECT quantityInStock
					   FROM products
					   WHERE orderdetails.productCode = products.productCode) AS lowStock
FROM orderdetails
GROUP BY productCode
ORDER BY lowStock DESC
LIMIT 10
)
SELECT productCode, SUM(quantityOrdered * priceEach) AS totalSales
FROM orderdetails
WHERE productCode IN (SELECT productCode FROM restockPriority)
GROUP BY productCode
ORDER BY totalSales DESC;

-- Profit by customer

SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
FROM orderdetails
JOIN orders
ON orderdetails.orderNumber = orders.orderNumber
JOIN products
ON orderdetails.productCode = products.productCode
GROUP BY customerNumber;

-- Top 5 VIP customers using views

CREATE VIEW vipCustomers AS
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
FROM orderdetails
JOIN orders
ON orderdetails.orderNumber = orders.orderNumber
JOIN products
ON orderdetails.productCode = products.productCode
GROUP BY customerNumber;

SELECT contactLastName, contactFirstName, city, country, profit
FROM customers
JOIN vipCustomers
ON customers.customerNumber = vipCustomers.customerNumber
ORDER BY profit DESC
LIMIT 5;

-- Top 5 least engaged customers

SELECT contactLastName, contactFirstName, city, country, profit
FROM customers
JOIN vipCustomers
ON customers.customerNumber = vipCustomers.customerNumber
ORDER BY profit
LIMIT 5;

-- Average of customer profits to determine how much can be spent on marketing to gain new customers

SELECT AVG(profit)
FROM vipCustomers;

