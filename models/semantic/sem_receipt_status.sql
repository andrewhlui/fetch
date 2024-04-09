{#
    When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
    When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
#}

select
    rewards_receipt_status, 
    avg(total_spent_amt_usd) as average_spend,
    sum(quantity_purchased) as purchased_item_count
from
    {{ ref('dim_receipts') }}
inner join
    {{ ref('fct_receipt_items') }}
group by all
