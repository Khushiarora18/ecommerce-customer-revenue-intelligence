/* ============================================================
   E-COMMERCE CUSTOMER & REVENUE INTELLIGENCE
   SQL Analysis Project
   Tools: MySQL
   Analysis Period: 2024-01-01 to 2025-12-31

   Tables:
   1. Customers
   2. Products
   3. Orders
   4. Order_Items
   5. Date

   Analysis:
   - Data Quality Checks
   - Revenue & Profitability
   - Category Performance
   - Product Performance
   - Customer Analysis
   - Acquisition Channel Analysis
   - RFM Customer Segmentation
   ============================================================ */


-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_customer_intelligence;

USE ecommerce_customer_intelligence;


-- ============================================================
-- 2. TABLE STRUCTURE
-- ============================================================

DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Date;


CREATE TABLE Customers (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Gender VARCHAR(20),
    Age INT,
    City VARCHAR(100),
    State VARCHAR(100),
    Acquisition_Channel VARCHAR(50),
    Signup_Date DATE
);


CREATE TABLE Products (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Name VARCHAR(150),
    Category VARCHAR(100),
    Subcategory VARCHAR(100),
    Unit_Cost DECIMAL(12,2),
    Selling_Price DECIMAL(12,2)
);


CREATE TABLE Orders (
    Order_ID VARCHAR(15) PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Order_Date DATE,
    Payment_Method VARCHAR(50),
    Order_Status VARCHAR(50),
    Shipping_Type VARCHAR(50),

    FOREIGN KEY (Customer_ID)
        REFERENCES Customers(Customer_ID)
);


CREATE TABLE Order_Items (
    Order_ID VARCHAR(15),
    Product_ID VARCHAR(10),
    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Discount DECIMAL(5,2),
    Revenue DECIMAL(14,2),
    Cost DECIMAL(14,2),
    Profit DECIMAL(14,2),

    FOREIGN KEY (Order_ID)
        REFERENCES Orders(Order_ID),

    FOREIGN KEY (Product_ID)
        REFERENCES Products(Product_ID)
);


CREATE TABLE Date (
    Date DATE PRIMARY KEY,
    Year INT,
    Month_Number INT,
    Month VARCHAR(20),
    Quarter VARCHAR(10),
    Year_Month VARCHAR(20),
    Weekday VARCHAR(20)
);


-- ============================================================
-- 3. DATA IMPORT
-- ============================================================
-- CSV files can be imported using MySQL Workbench's
-- Table Data Import Wizard.
--
-- Files:
-- Customers.csv
-- Products.csv
-- Orders.csv
-- Order_Items.csv
-- Date.csv
--
-- The tables above are intentionally separated so that
-- the CSV files can be imported into the corresponding tables.


-- ============================================================
-- 4. DATA QUALITY CHECKS
-- ============================================================

-- 4.1 Record counts

SELECT 'Customers' AS Table_Name, COUNT(*) AS Record_Count
FROM Customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM Products

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Orders

UNION ALL

SELECT 'Order_Items', COUNT(*)
FROM Order_Items

UNION ALL

SELECT 'Date', COUNT(*)
FROM Date;


-- 4.2 Duplicate Customer IDs

SELECT
    Customer_ID,
    COUNT(*) AS Duplicate_Count
FROM Customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;


-- 4.3 Duplicate Product IDs

SELECT
    Product_ID,
    COUNT(*) AS Duplicate_Count
FROM Products
GROUP BY Product_ID
HAVING COUNT(*) > 1;


-- 4.4 Duplicate Order IDs

SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM Orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;


-- 4.5 Orders without valid customers

SELECT
    o.Order_ID,
    o.Customer_ID
FROM Orders o
LEFT JOIN Customers c
    ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;


-- 4.6 Order items without valid orders

SELECT
    oi.Order_ID
FROM Order_Items oi
LEFT JOIN Orders o
    ON oi.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;


-- 4.7 Order items without valid products

SELECT
    oi.Product_ID
FROM Order_Items oi
LEFT JOIN Products p
    ON oi.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;


-- 4.8 Negative or invalid quantities

SELECT *
FROM Order_Items
WHERE Quantity <= 0;


-- 4.9 Negative financial values

SELECT *
FROM Order_Items
WHERE Revenue < 0
   OR Cost < 0
   OR Profit < 0;


-- 4.10 Missing values in key fields

SELECT
    SUM(Customer_ID IS NULL) AS Missing_Customer_ID,
    SUM(Customer_Name IS NULL) AS Missing_Customer_Name,
    SUM(Acquisition_Channel IS NULL) AS Missing_Acquisition_Channel
FROM Customers;


SELECT
    SUM(Product_ID IS NULL) AS Missing_Product_ID,
    SUM(Product_Name IS NULL) AS Missing_Product_Name,
    SUM(Category IS NULL) AS Missing_Category
FROM Products;


SELECT
    SUM(Order_ID IS NULL) AS Missing_Order_ID,
    SUM(Customer_ID IS NULL) AS Missing_Customer_ID,
    SUM(Order_Date IS NULL) AS Missing_Order_Date
FROM Orders;


-- ============================================================
-- 5. OVERALL BUSINESS PERFORMANCE
-- ============================================================

SELECT
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Cost), 2) AS Total_Cost,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(
        SUM(Profit) / NULLIF(SUM(Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM Order_Items;


-- ============================================================
-- 6. ORDER & CUSTOMER KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT o.Customer_ID) AS Active_Customers,
    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT oi.Order_ID), 0),
        2
    ) AS Average_Order_Value
FROM Order_Items oi
JOIN Orders o
    ON oi.Order_ID = o.Order_ID;


-- ============================================================
-- 7. MONTHLY REVENUE TREND
-- ============================================================

SELECT
    d.Year,
    d.Month_Number,
    d.Month,
    d.Year_Month,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Profit), 2) AS Profit
FROM Order_Items oi
JOIN Orders o
    ON oi.Order_ID = o.Order_ID
JOIN Date d
    ON o.Order_Date = d.Date
GROUP BY
    d.Year,
    d.Month_Number,
    d.Month,
    d.Year_Month
ORDER BY
    d.Year,
    d.Month_Number;


-- ============================================================
-- 8. YEARLY PERFORMANCE
-- ============================================================

SELECT
    YEAR(o.Order_Date) AS Year,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Cost), 2) AS Cost,
    ROUND(SUM(oi.Profit), 2) AS Profit,
    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    COUNT(DISTINCT o.Customer_ID) AS Customers
FROM Order_Items oi
JOIN Orders o
    ON oi.Order_ID = o.Order_ID
GROUP BY YEAR(o.Order_Date)
ORDER BY Year;


-- ============================================================
-- 9. CATEGORY PERFORMANCE
-- ============================================================

SELECT
    p.Category,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Cost), 2) AS Cost,
    ROUND(SUM(oi.Profit), 2) AS Profit,
    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent,
    ROUND(
        SUM(oi.Revenue) /
        (SELECT SUM(Revenue) FROM Order_Items) * 100,
        2
    ) AS Revenue_Share_Percent
FROM Order_Items oi
JOIN Products p
    ON oi.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Revenue DESC;


-- ============================================================
-- 10. SUBCATEGORY PERFORMANCE
-- ============================================================

SELECT
    p.Category,
    p.Subcategory,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Profit), 2) AS Profit,
    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM Order_Items oi
JOIN Products p
    ON oi.Product_ID = p.Product_ID
GROUP BY
    p.Category,
    p.Subcategory
ORDER BY Revenue DESC;


-- ============================================================
-- 11. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Subcategory,
    SUM(oi.Quantity) AS Units_Sold,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Profit), 2) AS Profit,
    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM Order_Items oi
JOIN Products p
    ON oi.Product_ID = p.Product_ID
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Subcategory
ORDER BY Revenue DESC
LIMIT 10;


-- ============================================================
-- 12. PRODUCT PROFITABILITY
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Profit), 2) AS Profit,
    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM Order_Items oi
JOIN Products p
    ON oi.Product_ID = p.Product_ID
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category
ORDER BY Profit DESC;


-- ============================================================
-- 13. ACQUISITION CHANNEL PERFORMANCE
-- ============================================================

SELECT
    c.Acquisition_Channel,
    COUNT(DISTINCT c.Customer_ID) AS Customers,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT o.Order_ID), 0),
        2
    ) AS Average_Order_Value,
    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT c.Customer_ID), 0),
        2
    ) AS Revenue_Per_Customer
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY c.Acquisition_Channel
ORDER BY Revenue DESC;


-- ============================================================
-- 14. ACQUISITION CHANNEL REVENUE SHARE
-- ============================================================

SELECT
    c.Acquisition_Channel,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(
        SUM(oi.Revenue) /
        (
            SELECT SUM(Revenue)
            FROM Order_Items
        ) * 100,
        2
    ) AS Revenue_Share_Percent
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY c.Acquisition_Channel
ORDER BY Revenue DESC;


-- ============================================================
-- 15. TOP CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.State,
    c.Acquisition_Channel,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT o.Order_ID), 0),
        2
    ) AS Average_Order_Value
FROM Customers c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.State,
    c.Acquisition_Channel
ORDER BY Revenue DESC
LIMIT 10;


-- ============================================================
-- 16. CUSTOMER PURCHASE FREQUENCY
-- ============================================================

SELECT
    o.Customer_ID,
    COUNT(DISTINCT o.Order_ID) AS Order_Frequency,
    ROUND(SUM(oi.Revenue), 2) AS Revenue
FROM Orders o
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY o.Customer_ID
ORDER BY Order_Frequency DESC;


-- ============================================================
-- 17. PAYMENT METHOD PERFORMANCE
-- ============================================================

SELECT
    o.Payment_Method,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Profit), 2) AS Profit,
    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM Orders o
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY o.Payment_Method
ORDER BY Revenue DESC;


-- ============================================================
-- 18. ORDER STATUS PERFORMANCE
-- ============================================================

SELECT
    o.Order_Status,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(SUM(oi.Profit), 2) AS Profit
FROM Orders o
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY o.Order_Status
ORDER BY Revenue DESC;


-- ============================================================
-- 19. SHIPPING TYPE PERFORMANCE
-- ============================================================

SELECT
    o.Shipping_Type,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT o.Order_ID), 0),
        2
    ) AS Average_Order_Value
FROM Orders o
JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID
GROUP BY o.Shipping_Type
ORDER BY Revenue DESC;


-- ============================================================
-- 20. CUSTOMER RFM ANALYSIS
-- ============================================================
-- Reference date: 2025-12-31
--
-- Recency:
-- Number of days since the customer's last purchase.
--
-- Frequency:
-- Number of distinct orders.
--
-- Monetary:
-- Total customer revenue.
--
-- NTILE(5):
-- Customers are divided into five groups for each metric.
-- Recency is scored in reverse because lower recency days
-- represent more recent purchases.


WITH CustomerMetrics AS (

    SELECT
        o.Customer_ID,

        DATEDIFF(
            '2025-12-31',
            MAX(o.Order_Date)
        ) AS Recency_Days,

        COUNT(DISTINCT o.Order_ID) AS Frequency,

        ROUND(SUM(oi.Revenue), 2) AS Monetary_Value

    FROM Orders o

    JOIN Order_Items oi
        ON o.Order_ID = oi.Order_ID

    GROUP BY o.Customer_ID
),

RFMScored AS (

    SELECT
        Customer_ID,
        Recency_Days,
        Frequency,
        Monetary_Value,

        6 - NTILE(5) OVER (
            ORDER BY Recency_Days ASC
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary_Value ASC
        ) AS M_Score

    FROM CustomerMetrics
)

SELECT
    Customer_ID,
    Recency_Days,
    Frequency,
    Monetary_Value,
    R_Score,
    F_Score,
    M_Score,

    CONCAT(
        R_Score,
        F_Score,
        M_Score
    ) AS RFM_Score,

    CASE

        WHEN R_Score >= 4
         AND F_Score >= 4
         AND M_Score >= 4
            THEN 'Champions'

        WHEN R_Score >= 3
         AND F_Score >= 4
         AND M_Score >= 3
            THEN 'Loyal Customers'

        WHEN R_Score <= 2
         AND F_Score >= 3
         AND M_Score >= 3
            THEN 'At Risk'

        WHEN R_Score <= 2
         AND M_Score >= 3
            THEN 'High Value - Inactive'

        WHEN R_Score >= 4
         AND F_Score >= 2
         AND M_Score >= 2
            THEN 'Potential Loyalists'

        WHEN R_Score >= 4
         AND F_Score <= 2
            THEN 'New / Emerging'

        ELSE 'Needs Attention'

    END AS Customer_Segment

FROM RFMScored
ORDER BY Monetary_Value DESC;


-- ============================================================
-- 21. RFM SEGMENT SUMMARY
-- ============================================================

WITH CustomerMetrics AS (

    SELECT
        o.Customer_ID,

        DATEDIFF(
            '2025-12-31',
            MAX(o.Order_Date)
        ) AS Recency_Days,

        COUNT(DISTINCT o.Order_ID) AS Frequency,

        SUM(oi.Revenue) AS Monetary_Value

    FROM Orders o

    JOIN Order_Items oi
        ON o.Order_ID = oi.Order_ID

    GROUP BY o.Customer_ID
),

RFMScored AS (

    SELECT
        Customer_ID,
        Recency_Days,
        Frequency,
        Monetary_Value,

        6 - NTILE(5) OVER (
            ORDER BY Recency_Days ASC
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary_Value ASC
        ) AS M_Score

    FROM CustomerMetrics
),

RFMSegmented AS (

    SELECT
        *,
        CASE

            WHEN R_Score >= 4
             AND F_Score >= 4
             AND M_Score >= 4
                THEN 'Champions'

            WHEN R_Score >= 3
             AND F_Score >= 4
             AND M_Score >= 3
                THEN 'Loyal Customers'

            WHEN R_Score <= 2
             AND F_Score >= 3
             AND M_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2
             AND M_Score >= 3
                THEN 'High Value - Inactive'

            WHEN R_Score >= 4
             AND F_Score >= 2
             AND M_Score >= 2
                THEN 'Potential Loyalists'

            WHEN R_Score >= 4
             AND F_Score <= 2
                THEN 'New / Emerging'

            ELSE 'Needs Attention'

        END AS Customer_Segment

    FROM RFMScored
)

SELECT
    Customer_Segment,
    COUNT(*) AS Customer_Count,
    ROUND(SUM(Monetary_Value), 2) AS Revenue,
    ROUND(AVG(Monetary_Value), 2) AS Average_Customer_Value,
    ROUND(AVG(Frequency), 2) AS Average_Order_Frequency,
    ROUND(AVG(Recency_Days), 2) AS Average_Recency_Days

FROM RFMSegmented

GROUP BY Customer_Segment

ORDER BY Revenue DESC;


-- ============================================================
-- 22. RFM SEGMENT REVENUE SHARE
-- ============================================================

WITH CustomerMetrics AS (

    SELECT
        o.Customer_ID,

        DATEDIFF(
            '2025-12-31',
            MAX(o.Order_Date)
        ) AS Recency_Days,

        COUNT(DISTINCT o.Order_ID) AS Frequency,

        SUM(oi.Revenue) AS Monetary_Value

    FROM Orders o

    JOIN Order_Items oi
        ON o.Order_ID = oi.Order_ID

    GROUP BY o.Customer_ID
),

RFMScored AS (

    SELECT
        *,
        6 - NTILE(5) OVER (
            ORDER BY Recency_Days ASC
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary_Value ASC
        ) AS M_Score

    FROM CustomerMetrics
),

RFMSegmented AS (

    SELECT
        *,
        CASE

            WHEN R_Score >= 4
             AND F_Score >= 4
             AND M_Score >= 4
                THEN 'Champions'

            WHEN R_Score >= 3
             AND F_Score >= 4
             AND M_Score >= 3
                THEN 'Loyal Customers'

            WHEN R_Score <= 2
             AND F_Score >= 3
             AND M_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2
             AND M_Score >= 3
                THEN 'High Value - Inactive'

            WHEN R_Score >= 4
             AND F_Score >= 2
             AND M_Score >= 2
                THEN 'Potential Loyalists'

            WHEN R_Score >= 4
             AND F_Score <= 2
                THEN 'New / Emerging'

            ELSE 'Needs Attention'

        END AS Customer_Segment

    FROM RFMScored
)

SELECT
    Customer_Segment,
    COUNT(*) AS Customers,
    ROUND(SUM(Monetary_Value), 2) AS Revenue,

    ROUND(
        SUM(Monetary_Value) /
        (
            SELECT SUM(Monetary_Value)
            FROM RFMSegmented
        ) * 100,
        2
    ) AS Revenue_Share_Percent

FROM RFMSegmented

GROUP BY Customer_Segment

ORDER BY Revenue DESC;


-- ============================================================
-- 23. HIGH-VALUE CUSTOMERS
-- ============================================================

WITH CustomerValue AS (

    SELECT
        o.Customer_ID,
        COUNT(DISTINCT o.Order_ID) AS Order_Count,
        SUM(oi.Revenue) AS Revenue

    FROM Orders o

    JOIN Order_Items oi
        ON o.Order_ID = oi.Order_ID

    GROUP BY o.Customer_ID
)

SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.State,
    cv.Order_Count,
    ROUND(cv.Revenue, 2) AS Revenue

FROM CustomerValue cv

JOIN Customers c
    ON cv.Customer_ID = c.Customer_ID

ORDER BY cv.Revenue DESC

LIMIT 20;


-- ============================================================
-- 24. CUSTOMER REVENUE BY CITY
-- ============================================================

SELECT
    c.City,
    c.State,
    COUNT(DISTINCT c.Customer_ID) AS Customers,
    COUNT(DISTINCT o.Order_ID) AS Orders,
    ROUND(SUM(oi.Revenue), 2) AS Revenue,
    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT c.Customer_ID), 0),
        2
    ) AS Revenue_Per_Customer

FROM Customers c

JOIN Orders o
    ON c.Customer_ID = o.Customer_ID

JOIN Order_Items oi
    ON o.Order_ID = oi.Order_ID

GROUP BY
    c.City,
    c.State

ORDER BY Revenue DESC;


-- ============================================================
-- 25. FINAL PROJECT KPI SUMMARY
-- ============================================================

SELECT
    ROUND(SUM(oi.Revenue), 2) AS Total_Revenue,
    ROUND(SUM(oi.Cost), 2) AS Total_Cost,
    ROUND(SUM(oi.Profit), 2) AS Total_Profit,

    ROUND(
        SUM(oi.Profit) /
        NULLIF(SUM(oi.Revenue), 0) * 100,
        2
    ) AS Profit_Margin_Percent,

    COUNT(DISTINCT o.Order_ID) AS Total_Orders,

    COUNT(DISTINCT o.Customer_ID) AS Active_Customers,

    ROUND(
        SUM(oi.Revenue) /
        NULLIF(COUNT(DISTINCT o.Order_ID), 0),
        2
    ) AS Average_Order_Value

FROM Order_Items oi

JOIN Orders o
    ON oi.Order_ID = o.Order_ID;


-- ============================================================
-- END OF PROJECT
-- ============================================================
