-- ============================================================
-- Online Retail BI Dashboard
-- File: create_tables.sql
-- Description: Creates the star schema tables in the dw schema
-- Run this FIRST before any ETL scripts
-- ============================================================
 
-- Create schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging')
 
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw')
 
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'rpt')
    EXEC('CREATE SCHEMA rpt')
 
-- Staging table (raw data lands here first)
CREATE TABLE staging.OnlineRetail (
    InvoiceNo    NVARCHAR(20),
    StockCode    NVARCHAR(20),
    Description  NVARCHAR(255),
    Quantity     NVARCHAR(20),
    InvoiceDate  NVARCHAR(30),
    UnitPrice    NVARCHAR(20),
    CustomerID   NVARCHAR(20),
    Country      NVARCHAR(100)
)
 
-- DimDate (730 rows covering 2 full years)
CREATE TABLE dw.DimDate (
    DateKey      INT PRIMARY KEY,
    FullDate     DATE NOT NULL,
    DayName      NVARCHAR(10),
    DayOfWeek    INT,
    DayOfMonth   INT,
    Month        INT,
    MonthName    NVARCHAR(10),
    Quarter      INT,
    Year         INT,
    IsWeekend    BIT
)
 
-- DimCustomer
CREATE TABLE dw.DimCustomer (
    CustomerKey  INT PRIMARY KEY IDENTITY(1,1),
    CustomerID   NVARCHAR(20),
    Country      NVARCHAR(100)
)
 
-- DimProduct
CREATE TABLE dw.DimProduct (
    ProductKey   INT PRIMARY KEY IDENTITY(1,1),
    StockCode    NVARCHAR(20),
    Description  NVARCHAR(255),
    UnitPrice    DECIMAL(10,2)
)
 
-- FactSales (central fact table)
CREATE TABLE dw.FactSales (
    SalesKey       INT PRIMARY KEY IDENTITY(1,1),
    InvoiceNo      NVARCHAR(20),
    DateKey        INT FOREIGN KEY REFERENCES dw.DimDate(DateKey),
    CustomerKey    INT FOREIGN KEY REFERENCES dw.DimCustomer(CustomerKey),
    ProductKey     INT FOREIGN KEY REFERENCES dw.DimProduct(ProductKey),
    Quantity       INT,
    UnitPrice      DECIMAL(10,2),
    LineTotal      DECIMAL(10,2),
    IsCancellation BIT,
    SalesKey_      INT
)
