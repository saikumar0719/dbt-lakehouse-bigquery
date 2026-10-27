{% snapshot customers_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at',
    )
}}
-- SCD Type 2: every change to a customer keeps the old row with a validity
-- window instead of overwriting it, so history is queryable.
-- Runs with `dbt snapshot` (production path); not part of `dbt build`.
select
    customer_id,
    first_name,
    last_name,
    email,
    country,
    signup_date,
    updated_at
from {{ ref('stg_customers') }}
{% endsnapshot %}
