-- Staging: bronze -> silver. Names and emails standardized by one macro,
-- so a cleaning rule change touches one file, not every model.
select
    customer_id,
    {{ clean_string('first_name') }} as first_name,
    {{ clean_string('last_name') }} as last_name,
    lower(trim(email)) as email,
    upper(trim(country)) as country,
    cast(signup_date as date) as signup_date,
    cast(updated_at as date) as updated_at
from {{ source('retail', 'customers') }}
where customer_id is not null
