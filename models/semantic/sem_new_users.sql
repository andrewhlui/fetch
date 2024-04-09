{#
    Which brand has the most spend among users who were created within the past 6 months?
    Which brand has the most transactions among users who were created within the past 6 months?
#}

select
    brand_name, 
    count(distinct fct_receipt_items.receipt_id) as transaction_count,
    sum(total_spent_amt_usd) as spent_amt_usd
from
    {{ ref('fct_receipt_items') }}
inner join
    {{ ref('dim_receipts') }}
    on dim_receipts.receipt_id = fct_receipt_items.receipt_id
inner join 
    {{ ref('dim_users') }}
    on dim_users.user_id = dim_receipts.user_id
inner join
    {{ ref('dim_brands') }}
    --this _should_ use brand_id but we don't have that -- in a prod setting we'd generate a brand_id to be joined here
    on cte_brands.brand_code = fct_receipt_items.brand_code
where 
    dim_users.created_timestamp >= dateadd('month', 6, current_timestamp())
group by all
