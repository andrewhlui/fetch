{#
    Deduplicate and standardize user information. Pull in mostly-empty records where there are relational integrity issues. 
#}

with cte_users as (

    --unique record per user_id
    select
        user_id,
        is_active,
        created_timestamp,
        role,
        sign_up_source,
        state,
        last_login_timestamp,
        1 as priority
    from 
        {{ ref('stg_users') }}
    qualify
        row_number() over (partition by user_id order by is_active, last_login_timestamp desc nulls last) = 1

), 

cte_receipts as (

    --unique record per user_id
    select distinct
        user_id,
        null as is_active,
        null as created_timestamp,
        null as role,
        null as sign_up_source,
        null as state,
        null as last_login_timestamp,
        2 as priority
    from 
        {{ ref('stg_receipts') }}

)

--if we get more sources, switch this out for a macro
select
    user_id,
    is_active,
    created_timestamp,
    role,
    sign_up_source,
    state,
    last_login_timestamp,
    priority
from 
    cte_users
union 
select
    user_id,
    is_active,
    created_timestamp,
    role,
    sign_up_source,
    state,
    last_login_timestamp,
    priority
from 
    cte_receipts
where user_id not in (select user_id from cte_users) = 1