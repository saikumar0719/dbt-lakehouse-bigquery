-- Gold mart: customer revenue, ranked. Built only from completed orders,
-- so cancelled/refunded revenue never inflates the ranking.
with completed as (
    select *
    from {{ ref('fct_orders') }}
    where status = 'completed'
),
customer_revenue as (
    select
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        c.country,
        count(*) as total_orders,
        sum(o.amount) as total_revenue,
        sum(o.amount) / nullif(count(*), 0) as avg_order_value,
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date
    from completed as o
    join {{ ref('dim_customers') }} as c
        on o.customer_id = c.customer_id
    group by c.customer_id, c.first_name, c.last_name, c.country
)
select
    *,
    rank() over (order by total_revenue desc) as revenue_rank
from customer_revenue
