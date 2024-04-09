{#
    Which brand has the most spend among users who were created within the past 6 months?
    Which brand has the most transactions among users who were created within the past 6 months?
#}

with cte_brands as (

    select
        brand_name,
        brand_code,
    from
        {{ ref('dim_brands') }}
    --deduplicate to the best of our ability, essentially... just pick one; as long as it's 
    qualify
        row_number() over (partition by brand_code order by brand_name desc) = 1
)

select
    brand_name, 
    count(distinct fct_receipt_items.receipt_id) as receipt_count,
    count(1) as transaction_count
from
    {{ ref('fct_receipt_items') }}
inner join
    {{ ref('dim_receipts') }}
    on dim_receipts.receipt_id = fct_receipt_items.receipt_id
inner join 
    {{ ref('dim_users') }}
    on dim_users.user_id = dim_receipts.user_id
inner join
    cte_brands
    on cte_brands.brand_code = fct_receipt_items.brand_code
where 
    dim_users.created_timestamp >= dateadd('month', 6, current_timestamp())
group by all
