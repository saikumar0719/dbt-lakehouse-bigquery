-- Gold dimension: one row per customer, with lifetime behavior rolled up.
-- Customers with no orders still appear (left join), with zero totals.
with order_stats as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(*) as total_orders,
        sum(case when status = 'completed' then amount else 0 end) as total_revenue
    from {{ ref('int_orders_enriched') }}
    group by customer_id
)
select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.signup_date,
    o.first_order_date,
    o.last_order_date,
    coalesce(o.total_orders, 0) as total_orders,
    coalesce(o.total_revenue, 0) as total_revenue
from {{ ref('stg_customers') }} as c
left join order_stats as o
    on c.customer_id = o.customer_id
