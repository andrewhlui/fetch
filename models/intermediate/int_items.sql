select
    barcode,
    description,
    brand_code,
    false as is_user_flagged
from
    {{ ref('int_receipt_items') }}
union
select
    user_flagged_barcode as barcode,
    user_flagged_description as description,
    null as brand_code,
    true as is_user_flagged
from
    {{ ref('int_receipt_items') }}
qualify
    row_number() over (partition by barcode order by is_user_flagged) = 1