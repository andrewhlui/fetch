{#
    Questions:
    What are the top 5 brands by receipts scanned for most recent month?
    How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
#}

with cte_monthly_brands as (

    select
        fct_receipt_items.brand_code,
        brand_name, 
        --personal preference to keep things as the first date of the month -- IMO easier to read than a plain number (e.g. month)
        date_trunc('month', created_timestamp::date) as start_of_month,
        count(distinct fct_receipt_items.receipt_id) as receipt_count,
        lag(receipt_count, 1, 0) over (partition by brand_name, fct_receipt_items.brand_code order by start_of_month) as receipt_count_prior_month
    from
        {{ ref('fct_receipt_items') }}
    inner join
        {{ ref('dim_receipts') }}
        on dim_receipts.receipt_id = fct_receipt_items.receipt_id
    left join
        {{ ref('dim_brands') }}
        --this _should_ use brand_id but we don't have that -- in a prod setting we'd generate a brand_id to be joined here
        on dim_brands.brand_code = fct_receipt_items.brand_code
    group by all

)

--technically returns more information than is needed, but users usually have additional questions on history after seeing month-over-month so this is pre-empting that
select
    brand_name,
    brand_code,
    start_of_month,
    receipt_count, 
    receipt_count_prior_month,
    rank() over (partition by start_of_month order by receipt_count) as rank,
    rank() over (partition by start_of_month order by receipt_count_prior_month) as rank_prior_month
from cte_monthly_brands
--only the top 5 brands for this month
qualify 
    rank <= 5