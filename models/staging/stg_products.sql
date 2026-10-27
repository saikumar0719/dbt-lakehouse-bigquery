-- Staging: bronze -> silver.
select
    product_id,
    {{ clean_string('product_name') }} as product_name,
    lower(trim(category)) as category,
    cast(unit_cost as double) as unit_cost
from {{ source('retail', 'products') }}
where product_id is not null
