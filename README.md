# dbt Lakehouse (Medallion Architecture)

A senior data engineering project: a retail lakehouse built with dbt on the
medallion pattern — bronze (raw) → silver (cleaned) → gold (marts) — with
dbt tests, documentation, a snapshot for slowly changing dimensions, and an
Airflow DAG to orchestrate it.

It runs **fully locally on DuckDB** (no cloud account, no cost), and the same
models deploy to BigQuery by swapping the profile.

## Architecture

```
data/*.csv ──► load_duckdb.py ──► bronze schema (raw tables)
                                          │
                                          ▼
                              staging models (silver)
                              clean, cast, standardize
                                          │
                                          ▼
                            intermediate model (silver)
                            orders enriched with customer
                            country + product category
                                          │
                        ┌─────────────────┴─────────────────┐
                        ▼                                     ▼
                 core marts (gold)                   marketing mart (gold)
                 dim_customers, dim_products,        mart_customer_revenue
                 fct_orders                          (ranked by revenue)
                        │
                        ▼
              dbt tests (unique, not_null,
              relationships, accepted_values,
              custom singular test)
                        │
                        ▼
              Airflow DAG: dbt build → dbt docs
```

## Layers

| Layer | Location | What lives there |
| --- | --- | --- |
| Bronze | `bronze` schema | Raw source tables, untouched |
| Silver | `silver` schema | Staging + intermediate: cleaned, typed, joined |
| Gold | `gold` schema | Dimensions, facts, and business marts |

## Run it locally (DuckDB, free)

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate | Mac/Linux: source .venv/bin/activate
pip install -r requirements.txt

# 1. Generate the sample data (already committed under data/, re-run anytime)
python scripts/generate_sample_data.py

# 2. Load it into the bronze schema
python scripts/load_duckdb.py

# 3. Build everything: models + tests
dbt build --profiles-dir .

# 4. Look at a mart
python -c "
import duckdb
con = duckdb.connect('lakehouse.duckdb', read_only=True)
print(con.execute('select * from analytics_gold.mart_customer_revenue order by revenue_rank limit 5').fetchall())
"
```

## Run it on BigQuery (production path)

1. Create the datasets with Terraform in `terraform/` (bronze, silver, gold).
2. Load your raw tables into the bronze dataset.
3. Copy `profiles.example.yml` to `~/.dbt/profiles.yml`, fill in your project.
4. In `models/sources.yml`, set the source schema to your bronze dataset name.
5. Run `dbt build --target prod`.

## Repository layout

| Path | What it is |
| --- | --- |
| `models/sources.yml` | Raw source definitions |
| `models/staging/` | Bronze → silver cleaning models + tests |
| `models/intermediate/` | Enriched order lines (silver) |
| `models/marts/core/` | Dimensions + fact (gold) |
| `models/marts/marketing/` | Customer revenue mart (gold) |
| `macros/` | Reusable SQL (string cleaning) |
| `snapshots/` | SCD Type 2 customer snapshot (BigQuery prod) |
| `analyses/` | Ad-hoc analysis queries (not materialized) |
| `tests/singular/` | Custom data test: no non-positive revenue |
| `orchestration/dags/` | Airflow DAG for Composer |
| `terraform/` | BigQuery datasets for the prod path |
| `scripts/` | Sample-data generator + DuckDB loader |
| `data/` | Sample CSVs (regenerable) |
| `docs/` | Medallion design notes + lineage |

## What this demonstrates (recruiter talking points)

- **Medallion architecture:** bronze raw, silver cleaned, gold business-ready —
  each layer has one job, and marts never read raw tables directly.
- **dbt tests as gates:** unique/not_null keys, relationships between fact and
  dimensions, accepted values for order status, plus a custom singular test
  that fails the build if any order has non-positive revenue.
- **SCD Type 2:** the customer snapshot tracks history with `updated_at`, so a
  changed customer record keeps its old version instead of overwriting it.
- **Macros over copy-paste:** string cleaning lives in one macro used by every
  staging model, so a rule change touches one file.
- **Docs and lineage:** `dbt docs` generates the lineage graph from the same
  code — the documentation cannot drift from the pipeline.
- **Orchestration:** the Airflow DAG runs `dbt build` then `dbt docs generate`
  with retries and an SLA, so a failed build blocks stale docs, not just logs.
- **Portable SQL:** models use standard SQL plus dbt's cross-database macros,
  so the same code runs on DuckDB locally and BigQuery in production.

## Cost notes

Local DuckDB runs cost nothing. On BigQuery, the sample volumes are tiny;
the only thing to watch is leaving a Composer environment running — create
it only when testing the DAG, delete it after.
