-- ============================================================
-- Online Retail BI Dashboard
-- File: etl_factsales.sql
-- Description: Loads DimCustomer, DimProduct, and FactSales
--              from the staging table
-- Run AFTER create_tables.sql
-- ============================================================
 
 
-- STEP 1: Load DimCustomer
-- Insert one Unknown record first to handle NULL CustomerIDs
INSERT INTO dw.DimCustomer (CustomerID, Country)
VALUES ('Unknown', 'Unknown')
 
-- Insert one row per unique customer from staging
INSERT INTO dw.DimCustomer (CustomerID, Country)
SELECT DISTINCT
    CustomerID,
    Country
FROM staging.OnlineRetail
WHERE CustomerID IS NOT NULL
AND CustomerID != ''
ORDER BY CustomerID
 
 
-- STEP 2: Load DimProduct
-- Insert one Unknown record first
INSERT INTO dw.DimProduct (StockCode, Description, UnitPrice)
VALUES ('Unknown', 'Unknown Product', 0)
 
-- Insert one row per unique StockCode
-- Takes the most recent description and average unit price
INSERT INTO dw.DimProduct (StockCode, Description, UnitPrice)
SELECT
    StockCode,
    MAX(Description) AS Description,
    AVG(CAST(REPLACE(UnitPrice, ',', '.') AS DECIMAL(10,2))) AS UnitPrice
FROM staging.OnlineRetail
WHERE StockCode IS NOT NULL
AND StockCode != ''
GROUP BY StockCode
 
 
-- STEP 3: Load FactSales
-- Joins staging back to all three dimensions to get surrogate keys
-- Calculates LineTotal and flags cancellations
INSERT INTO dw.FactSales (
    InvoiceNo,
    DateKey,
    CustomerKey,
    ProductKey,
    Quantity,
    UnitPrice,
    LineTotal,
    IsCancellation
)
SELECT
    s.InvoiceNo,
 
    -- DateKey: converts InvoiceDate string to INT key (YYYYMMDD format)
    CAST(FORMAT(CAST(s.InvoiceDate AS DATE), 'yyyyMMdd') AS INT) AS DateKey,
 
    -- CustomerKey: use Unknown (key=1) if CustomerID is NULL or empty
    COALESCE(c.CustomerKey, 1) AS CustomerKey,
 
    -- ProductKey: use Unknown (key=1) if StockCode not found
    COALESCE(p.ProductKey, 1) AS ProductKey,
 
    CAST(s.Quantity AS INT) AS Quantity,
    CAST(REPLACE(s.UnitPrice, ',', '.') AS DECIMAL(10,2)) AS UnitPrice,
 
    -- LineTotal = Quantity x UnitPrice
    CAST(s.Quantity AS INT) * CAST(REPLACE(s.UnitPrice, ',', '.') AS DECIMAL(10,2)) AS LineTotal,
 
    -- IsCancellation = 1 if InvoiceNo starts with C
    CASE WHEN LEFT(s.InvoiceNo, 1) = 'C' THEN 1 ELSE 0 END AS IsCancellation
 
FROM staging.OnlineRetail s
 
LEFT JOIN dw.DimCustomer c
    ON s.CustomerID = c.CustomerID
 
LEFT JOIN dw.DimProduct p
    ON s.StockCode = p.StockCode
 
WHERE s.Quantity != ''
AND s.UnitPrice != ''
AND s.InvoiceDate != ''
 
 
-- STEP 4: Validate the results
-- These numbers should match exactly:
-- DimCustomer rows: 4,381 (plus 1 Unknown = 4,382 total)
-- DimProduct rows:  3,848 (plus 1 Unknown = 3,849 total)
-- FactSales rows:   541,799
-- Total Revenue (excluding cancellations): £10,644,560.42
 
SELECT 'DimCustomer' AS TableName, COUNT(*) AS RowCount FROM dw.DimCustomer
UNION ALL
SELECT 'DimProduct',  COUNT(*) FROM dw.DimProduct
UNION ALL
SELECT 'FactSales',   COUNT(*) FROM dw.FactSales
 
-- Revenue validation (should return 10,644,560.42)
SELECT
    SUM(LineTotal) AS TotalRevenue
FROM dw.FactSales
WHERE IsCancellation = 0
 
-- Orphaned key check (should return 0 for all three)
SELECT 'Orphaned DateKey'     AS Check_, COUNT(*) AS Count FROM dw.FactSales WHERE DateKey NOT IN (SELECT DateKey FROM dw.DimDate)
UNION ALL
SELECT 'Orphaned CustomerKey', COUNT(*) FROM dw.FactSales WHERE CustomerKey NOT IN (SELECT CustomerKey FROM dw.DimCustomer)
UNION ALL
SELECT 'Orphaned ProductKey',  COUNT(*) FROM dw.FactSales WHERE ProductKey  NOT IN (SELECT ProductKey  FROM dw.DimProduct)
