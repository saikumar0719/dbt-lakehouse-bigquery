-- Gold dimension: one row per product, with lifetime sales rolled up.
select
    p.product_id,
    p.product_name,
    p.category,
    p.unit_cost,
    coalesce(sum(case when o.status = 'completed' then o.quantity else 0 end), 0)
        as total_units_sold,
    coalesce(sum(case when o.status = 'completed' then o.amount else 0 end), 0)
        as total_revenue
from {{ ref('stg_products') }} as p
left join {{ ref('int_orders_enriched') }} as o
    on p.product_id = o.product_id
group by p.product_id, p.product_name, p.category, p.unit_cost
