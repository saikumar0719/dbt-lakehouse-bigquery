"""Load the sample CSVs into the bronze schema of the local DuckDB file.

Creates lakehouse.duckdb (or replaces the bronze tables in it) so that
`dbt build --profiles-dir .` can resolve {{ source('retail', ...) }}.
Run: python scripts/load_duckdb.py
"""

from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "lakehouse.duckdb"

TABLES = {
    "orders": (
        "order_id, customer_id, product_id, "
        "CAST(order_date AS DATE) AS order_date, "
        "CAST(quantity AS INTEGER) AS quantity, "
        "CAST(unit_price AS DOUBLE) AS unit_price, status"
    ),
    "customers": (
        "customer_id, first_name, last_name, email, country, "
        "CAST(signup_date AS DATE) AS signup_date, "
        "CAST(updated_at AS DATE) AS updated_at"
    ),
    "products": (
        "product_id, product_name, category, CAST(unit_cost AS DOUBLE) AS unit_cost"
    ),
}

con = duckdb.connect(str(DB_PATH))
con.execute("CREATE SCHEMA IF NOT EXISTS bronze")
for table, columns in TABLES.items():
    csv_path = ROOT / "data" / f"raw_{table}.csv"
    con.execute(f"CREATE OR REPLACE TABLE bronze.{table} AS "
                f"SELECT {columns} FROM read_csv('{csv_path}', header=true, all_varchar=true)")
    count = con.execute(f"SELECT COUNT(*) FROM bronze.{table}").fetchone()[0]
    print(f"bronze.{table}: {count} rows")
con.close()
print(f"Done -> {DB_PATH}")
