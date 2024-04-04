-- All scenarios are based on Database NORTHWIND.

-- 1.      List all cities that have both Employees and Customers.

SELECT DISTINCT c.City
FROM Customers c
INNER JOIN Employees e ON c.City = e.City;

-- 2.      List all cities that have Customers but no Employee.
-- a.      Use sub-query

SELECT DISTINCT City
FROM Customers
WHERE City NOT IN (
    SELECT City FROM Employees
);

-- b.      Do not use sub-query

SELECT DISTINCT c.City
FROM Customers c
LEFT JOIN Employees e ON c.City = e.City
WHERE e.City IS NULL;

-- 3.      List all products and their total order quantities throughout all orders.

SELECT p.ProductName, SUM(od.Quantity) AS TotalOrdered
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY TotalOrdered DESC;

-- 4.      List all Customer Cities and total products ordered by that city.

SELECT c.City, SUM(od.Quantity) AS TotalProductsOrdered
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.City
ORDER BY TotalProductsOrdered DESC;

-- 5.      List all Customer Cities that have at least two customers.
-- a.      Use union

SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(*) > 1
UNION
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(*) > 1;

-- b.      Use sub-query and no union

SELECT City
FROM Customers
WHERE City IN (
    SELECT City 
    FROM Customers
    GROUP BY City
    HAVING COUNT(CustomerID) >= 2
)
GROUP BY City;

-- 6.      List all Customer Cities that have ordered at least two different kinds of products.

SELECT o.ShipCity
FROM Orders o
JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.ShipCity
HAVING COUNT(DISTINCT od.ProductID) >= 2;

-- 7.      List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.

SELECT DISTINCT c.ContactName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.ShipCity <> c.City;

-- 8.      List 5 most popular products, their average price, and the customer city that ordered most quantity of it.

SELECT TOP 5 p.ProductName, AVG(od.UnitPrice) AS AveragePrice, MAX(c.City) AS TopCustomerCity
FROM [Order Details] od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY SUM(od.Quantity) DESC;

-- 9.      List all cities that have never ordered something but we have employees there.
-- a.      Use sub-query

SELECT DISTINCT e.City
FROM Employees e
WHERE e.City NOT IN (
    SELECT o.ShipCity FROM Orders o
);

-- b.      Do not use sub-query

SELECT DISTINCT e.City
FROM Employees e
LEFT JOIN Orders o ON e.City = o.ShipCity
WHERE o.ShipCity IS NULL;

-- 10.  List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)

WITH EmployeeSales AS (
    SELECT e.City, COUNT(o.OrderID) AS Orders, SUM(od.Quantity) AS Quantities
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY e.City
),
MaxOrders AS (
    SELECT TOP 1 City
    FROM EmployeeSales
    ORDER BY Orders DESC
),
MaxQuantities AS (
    SELECT TOP 1 City
    FROM EmployeeSales
    ORDER BY Quantities DESC
)
SELECT mO.City AS MaxOrderCity, mQ.City AS MaxQuantityCity
FROM MaxOrders mO, MaxQuantities mQ;

-- 11. How do you remove the duplicates record of a table?

-- Answer: I may use DELETE JOIN or Temporary Table to remove the duplicates record of a table.