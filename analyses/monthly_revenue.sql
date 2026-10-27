-- Analysis (not materialized): monthly completed revenue trend.
-- Uses dbt's cross-database date macro so it runs on DuckDB and BigQuery.
select
    {{ dbt.date_trunc('month', 'order_date') }} as order_month,
    sum(amount) as revenue,
    count(*) as orders
from {{ ref('fct_orders') }}
where status = 'completed'
group by 1
order by 1
