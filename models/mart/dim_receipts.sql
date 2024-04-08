
select
    receipt_id,
    created_timestamp,
    scanned_timestamp,
    modified_timestamp,
    rewards_receipt_status,
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
    {{ ref('int_receipts') }}