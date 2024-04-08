{# 
    Unique items in each receipt. 
#}

with cte_receipts as (
select
    receipt_id,
    rewards_receipt_item_array from {{ ref('int_receipts') }}
    )
select
    cte_receipts.receipt_id,
    --there are more columns than this but mapping them all out will take too long; this is a subset
    flattened.value:"barcode"::varchar as barcode,
    flattened.value:"description"::varchar as description,
    flattened.value:"finalPrice" as final_price,
    flattened.value:"itemPrice" as item_price,
    flattened.value:"needsFetchReview" as needs_fetch_review,
    flattened.value:"partnerItemId"::varchar as partner_item_id,
    flattened.value:"preventTargetGapPoints" as prevent_target_gap_points,
    flattened.value:"quantityPurchased" as quantity_purchased,
    flattened.value:"userFlaggedBarcode" as user_flagged_barcode,
    flattened.value:"userFlaggedDescription" as user_flagged_description,
    flattened.value:"userFlaggedNewItem" as user_flagged_new_item,
    flattened.value:"userFlaggedPrice" as user_flagged_price,
    flattened.value:"userFlaggedQuantity" as user_flagged_quantity,
    flattened.value:"pointsEarned" as points_earned,
    flattened.value:"pointsPayerId" as points_payer_id,
    flattened.value:"rewardsGroup" as rewards_group,
    flattened.value:"rewardsProductPartnerId" as rewards_product_partner_id,
    flattened.value:"targetPrice" as target_price,
    flattened.value:"brandCode" as brand_code,
    flattened.value:"competitiveProduct" as competitive_product,
    flattened.value:"competitorRewardsGroup" as competitor_rewards_group,
    flattened.value:"discountedItemPrice" as discounted_item_price,
    flattened.value:"itemNumber" as item_number,
    flattened.value:"originalReceiptItemText" as original_receipt_item_text,

from
    cte_receipts, 
    lateral flatten(input => rewards_receipt_item_array) as flattened