select
    barcode,
    description,
    brand_code,
    is_user_flagged
from
    {{ ref('int_items') }}