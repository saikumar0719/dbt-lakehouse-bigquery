-- Gold fact: one row per order. Grain is the order, measures are additive,
-- and the status flag lets marts filter without re-deriving logic.
select
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    unit_price,
    amount,
    status,
    case when status = 'completed' then 1 else 0 end as is_completed
from {{ ref('int_orders_enriched') }}
