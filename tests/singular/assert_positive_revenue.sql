-- Singular test: fails the build if any order has non-positive revenue.
-- A passing test returns zero rows.
select
    order_id,
    amount
from {{ ref('fct_orders') }}
where amount <= 0
