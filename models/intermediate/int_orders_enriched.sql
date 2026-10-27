-- Intermediate: silver. Orders enriched with customer country and product
-- category. Still no business aggregation here — that belongs in the marts.
select
    o.order_id,
    o.customer_id,
    o.product_id,
    o.order_date,
    o.quantity,
    o.unit_price,
    o.amount,
    o.status,
    c.country as customer_country,
    p.product_name,
    p.category as product_category
from {{ ref('stg_orders') }} as o
left join {{ ref('stg_customers') }} as c
    on o.customer_id = c.customer_id
left join {{ ref('stg_products') }} as p
    on o.product_id = p.product_id
