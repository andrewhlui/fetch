
select
    receipt_id,
    created_timestamp,
    scanned_timestamp,
    modified_timestamp,
    rewards_receipt_status,
    rewards_receipt_item_array,
    user_id,
    total_spent_amt_usd,
    purchased_timestamp,
    purchased_item_count,
    points_earned,
    finished_timestamp,
    bonus_points_earned,
    bonus_points_earned_reason,
    points_awarded_timestamp
from
    {{ ref('stg_receipts') }}

--deduplicate to the best of our ability based on business logic
qualify
    row_number() over (partition by receipt_id order by created_timestamp desc nulls last, modified_timestamp desc nulls last, finished_timestamp desc nulls last) = 1