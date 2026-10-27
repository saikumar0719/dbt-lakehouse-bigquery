# Medallion design notes

## Why three layers

- **Bronze** is a faithful copy of source data. Nothing is cleaned here, so a
  bad transformation can always be rebuilt from bronze without re-extracting.
- **Silver** is where cleaning and typing happen (casts, standardization,
  null filtering) and where tables are joined. No business aggregation here.
- **Gold** is the only layer dashboards and analysts read. Every gold model
  has tests on its keys, so a broken join fails the build instead of
  silently shipping wrong numbers.

## Lineage

```
bronze.orders ──► stg_orders ──┐
bronze.customers ─► stg_customers ─► int_orders_enriched ──► fct_orders ──► mart_customer_revenue
bronze.products ──► stg_products ──┘                         │
                                                              ▼
                                              dim_customers, dim_products
```

## Key decisions

- **Staging does no business logic.** If a revenue definition changes, only
  the gold mart changes — staging stays stable.
- **Facts carry flags, not filters.** `fct_orders.is_completed` lets each
  mart decide what counts, instead of baking one definition into the fact.
- **Dimensions keep customers with no orders** (left join, zero totals), so a
  new customer is visible before their first order.
- **Snapshots, not overwrites, for customer history.** The SCD Type 2
  snapshot keeps old versions queryable when a customer record changes.
- **Tests are part of the build.** `dbt build` runs models and tests
  together; a failed relationship test stops the pipeline before gold
  updates.
