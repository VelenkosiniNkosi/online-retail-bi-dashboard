# Online Retail BI Dashboard
**Tools:** Python · SQL Server · Power BI · DAX · Star Schema · ETL

A complete end-to-end Business Intelligence project — from 541,909 rows 
of raw retail data to a 6-page executive Power BI dashboard.

## What This Project Does
Transforms raw transactional CSV data into a professional executive 
dashboard using a full BI pipeline.

## Project Architecture
- **Day 1** — Python ETL: 541,909 rows loaded into SQL Server staging table
- **Day 2** — Star schema designed: DimDate, DimCustomer, DimProduct, FactSales
- **Day 3** — Full ETL: 541,799 clean rows, £10,644,560.42 revenue validated, 0 orphaned keys
- **Day 4** — 5 analytical SQL views built in rpt schema
- **Day 5** — Power BI connected, 9 DAX measures written and validated
- **Day 6** — 6-page executive dashboard built
- **Day 7** — Dashboard polished with slicers, insights, and CEO recommendations

## Key Findings
- November peak revenue: £1.5M (+78% year-on-year)
- UK = ~75% of £10.6M total revenue across 38 countries
- No Saturday trading — confirms pure B2B wholesale business
- USA flagged at ~38% return rate — highest risk market
- Average order value: £484 — confirms bulk wholesale behaviour
- Overall return rate: 1.71% — healthy for wholesale retail

## Dashboard Pages
| Page | What It Shows |
|------|--------------|
| Executive Summary | 4 KPI cards + revenue trend line chart |
| Sales Trends | Monthly revenue + day-of-week analysis |
| Product Performance | Top 10 products by revenue |
| Customer & Geography | World map + top 10 countries |
| Returns Analysis | Return rate trends + highest-risk markets |
| Key Insights | CEO-level recommendations |

## How to Run This Project

### Requirements
- Python 3.8+
- SQL Server (or SQL Server Express)
- Power BI Desktop (free download from Microsoft)

### Steps
1. Clone this repo
2. Run `pip install pandas sqlalchemy pyodbc`
3. Run `python ingest.py` to load data into SQL Server
4. Run the SQL scripts in order (Day 2 → Day 3 → Day 4)
5. Open `OnlineRetail_BI_Darrell.pbix` in Power BI Desktop
6. Update the SQL Server connection to your local instance

## Screenshots
![Executive Summary](screenshots/EXECUTIVE%20SUMMARY.png)
![Sales Trends](screenshots/SALES%20TRENDS.png)
![Product Performance](screenshots/PRODUCT%20PERFORMANCE.png)
![Customer Geography](screenshots/CUSTOMER%20%26%20GEOGRAPHY.png)
![Returns Analysis](screenshots/RETURNS%20ANALYSIS.png)
![Key Insights](screenshots/KEY%20INSIGHTS.png)

## Built By
**Darrell Velenkosini Nkosi**
BCIS Honours Student — University of the Free State
IBM Award (2024) | BBD Award (2025)
[Portfolio](https://darrellnkosi.vercel.app) | 
[LinkedIn](https://www.linkedin.com/in/darrell-nkosi-86797a28b)
