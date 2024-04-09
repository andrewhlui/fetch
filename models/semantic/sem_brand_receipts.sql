{#
    Questions:
    What are the top 5 brands by receipts scanned for most recent month?
    How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
#}


{# 
    Normally I would standardize the dimension and the fact to have the same id (e.g. brand_id) so the joins would be neater
    `brand_id` would be a hashed version of whatever the natural key of the table is (brand code or brand name)
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
),

cte_monthly_brands as (

select
    fct_receipt_items.brand_code,
    brand_name, 
    date_trunc('month', created_timestamp::date) as start_of_month,
    count(distinct fct_receipt_items.receipt_id) as receipt_count,
    lag(receipt_count, 1, 0) over (partition by brand_name, fct_receipt_items.brand_code order by start_of_month) as receipt_count_prior_month
from
    {{ ref('fct_receipt_items') }}
inner join
    {{ ref('dim_receipts') }}
    on dim_receipts.receipt_id = fct_receipt_items.receipt_id
left join
    cte_brands
    on cte_brands.brand_code = fct_receipt_items.brand_code
group by all

)

select
    brand_name,
    brand_code,
    start_of_month,
    receipt_count, 
    receipt_count_prior_month,
    rank() over (partition by start_of_month order by receipt_count) as rank,
    rank() over (partition by start_of_month order by receipt_count_prior_month) as rank_prior_month
from cte_monthly_brands