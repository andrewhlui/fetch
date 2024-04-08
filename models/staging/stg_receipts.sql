select
    $1:_id:"$oid"::varchar as receipt_id,
    $1:createDate:"$date"::varchar::timestamp as created_timestamp,
    $1:dateScanned:"$date"::varchar::timestamp as scanned_timestamp,
    $1:modifyDate:"$date"::varchar::timestamp as modified_timestamp,
    $1:rewardsReceiptStatus::varchar as rewards_receipt_status,
    $1:userId::varchar as user_id,
    $1:totalSpent::varchar as total_spent_amt_usd,
    $1:rewardsReceiptItemList as rewards_receipt_item_array,
    $1:purchaseDate:"$date"::varchar::timestamp as purchased_timestamp,
    $1:purchasedItemCount::int as purchased_item_count,
    $1:pointsEarned::int as points_earned,
    $1:finishedDate:"$date"::varchar::timestamp as finished_timestamp,
    $1:bonusPointsEarned::int as bonus_points_earned,
    $1:bonusPointsEarnedReason::varchar as bonus_points_earned_reason,
    $1:pointsAwardedDate:"$date"::varchar::timestamp as points_awarded_timestamp
from
    {{ all_files('fetch_stage/receipts')}}