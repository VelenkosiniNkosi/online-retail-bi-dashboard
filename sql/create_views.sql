-- ============================================================
-- Online Retail BI Dashboard
-- File: create_views.sql
-- Description: Creates the 5 analytical views in the rpt schema
--              These feed directly into the Power BI data model
-- Run AFTER etl_factsales.sql
-- ============================================================
 
 
-- VIEW 1: Monthly Sales
-- Shows total revenue, orders, and average order value by month
CREATE OR ALTER VIEW rpt.vw_MonthlySales AS
SELECT
    d.Year,
    d.Month,
    d.MonthName,
    SUM(f.LineTotal)                        AS TotalRevenue,
    COUNT(DISTINCT f.InvoiceNo)             AS TotalOrders,
    AVG(f.LineTotal)                        AS AvgOrderLineValue,
    COUNT(DISTINCT f.CustomerKey)           AS UniqueCustomers
FROM dw.FactSales f
JOIN dw.DimDate d ON f.DateKey = d.DateKey
WHERE f.IsCancellation = 0
GROUP BY d.Year, d.Month, d.MonthName
 
 
-- VIEW 2: Top Products
-- Shows revenue and orders per product, ranked highest first
CREATE OR ALTER VIEW rpt.vw_TopProducts AS
SELECT
    p.StockCode,
    p.Description,
    SUM(f.LineTotal)            AS TotalRevenue,
    COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
    SUM(f.Quantity)             AS TotalUnitsSold,
    AVG(f.UnitPrice)            AS AvgSellingPrice
FROM dw.FactSales f
JOIN dw.DimProduct p ON f.ProductKey = p.ProductKey
WHERE f.IsCancellation = 0
AND p.StockCode != 'Unknown'
GROUP BY p.StockCode, p.Description
 
 
-- VIEW 3: Geographic Revenue
-- Shows revenue breakdown by country
CREATE OR ALTER VIEW rpt.vw_GeoRevenue AS
SELECT
    c.Country,
    SUM(f.LineTotal)                AS TotalRevenue,
    COUNT(DISTINCT f.InvoiceNo)     AS TotalOrders,
    COUNT(DISTINCT f.CustomerKey)   AS UniqueCustomers,
    AVG(f.LineTotal)                AS AvgOrderLineValue
FROM dw.FactSales f
JOIN dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE f.IsCancellation = 0
GROUP BY c.Country
 
 
-- VIEW 4: Return Rate
-- Shows cancellation rate overall and by country
CREATE OR ALTER VIEW rpt.vw_ReturnRate AS
SELECT
    c.Country,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN f.IsCancellation = 1 THEN 1 ELSE 0 END) AS Returns,
    SUM(CASE WHEN f.IsCancellation = 0 THEN 1 ELSE 0 END) AS NormalSales,
    CAST(SUM(CASE WHEN f.IsCancellation = 1 THEN 1 ELSE 0 END) AS FLOAT)
        / CAST(COUNT(*) AS FLOAT) AS ReturnRatePct,
    SUM(CASE WHEN f.IsCancellation = 1 THEN ABS(f.LineTotal) ELSE 0 END) AS RevenueAtRisk
FROM dw.FactSales f
JOIN dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY c.Country
 
 
-- VIEW 5: Day of Week Sales
-- Shows which days of the week drive the most revenue
CREATE OR ALTER VIEW rpt.vw_DayOfWeek AS
SELECT
    d.DayName,
    d.DayOfWeek,
    SUM(f.LineTotal)            AS TotalRevenue,
    COUNT(DISTINCT f.InvoiceNo) AS TotalOrders,
    COUNT(*)                    AS TotalTransactionLines,
    AVG(f.LineTotal)            AS AvgOrderLineValue
FROM dw.FactSales f
JOIN dw.DimDate d ON f.DateKey = d.DateKey
WHERE f.IsCancellation = 0
GROUP BY d.DayName, d.DayOfWeek
