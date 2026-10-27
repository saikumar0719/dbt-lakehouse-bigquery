-- Staging: bronze -> silver. One job only: clean and type, no business logic.
-- Grain: one row per order.
select
    order_id,
    customer_id,
    product_id,
    cast(order_date as date) as order_date,
    cast(quantity as integer) as quantity,
    cast(unit_price as double) as unit_price,
    cast(quantity as integer) * cast(unit_price as double) as amount,
    lower(trim(status)) as status
from {{ source('retail', 'orders') }}
where order_id is not null
