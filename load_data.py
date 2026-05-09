import pandas as pd
import pyodbc

conn = pyodbc.connect(
    "DRIVER={SQL Server};"
    "SERVER=CSI_HON14\\SQLEXPRESS;"
    "DATABASE=OnlineRetailDW;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()

cursor.execute("TRUNCATE TABLE staging.OnlineRetail")
conn.commit()
print("Table cleared.")

print("Reading CSV file... (this may take 30 seconds)")
df = pd.read_csv(
    r'C:\Data\online_retail.csv',
    dtype=str,
    encoding='utf-8-sig',
    keep_default_na=False,
    sep=';'
)

print(f"CSV has {len(df.columns)} columns: {list(df.columns)}")
print(f"Loaded {len(df):,} rows from CSV.")

df.columns = ['InvoiceNo','StockCode','Description','Quantity','InvoiceDate','UnitPrice','CustomerID','Country']
df = df.dropna(how='all')

print(f"After cleaning: {len(df):,} rows to insert.")
print("Now inserting into SQL Server...")

batch_size = 1000
total = len(df)

for i in range(0, total, batch_size):
    batch = df.iloc[i:i+batch_size]
    rows = [tuple(row) for _, row in batch.iterrows()]
    cursor.executemany(
        "INSERT INTO staging.OnlineRetail (InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,CustomerID,Country) VALUES (?,?,?,?,?,?,?,?)",
        rows
    )
    conn.commit()
    print(f"  Inserted {min(i+batch_size, total):,} of {total:,} rows...")

print("DONE! All rows loaded successfully.")
conn.close()