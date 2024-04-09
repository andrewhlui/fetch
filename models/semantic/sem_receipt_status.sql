{#
    When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
    When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
#}

select
    rewards_receipt_status, 
    avg(total_spent_amt_usd) as average_spend,
    --assuming that the number of items purchased is based on the individual items in receipts
    sum(quantity_purchased) as purchased_item_count
from
    {{ ref('dim_receipts') }}
inner join
    {{ ref('fct_receipt_items') }}
    on dim_receipts.receipt_id = fct_receipt_items.receipt_id
group by all
