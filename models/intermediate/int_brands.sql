select
	brand_id,
	barcode,
	cpg_id,
	cpg_ref,
	brand_name,
	category_name,
	brand_code,
	is_top_brand,
	category_code
from
    {{ ref('stg_brands') }}
qualify
    row_number() over (partition by brand_id order by brand_name desc nulls last, brand_code desc nulls last, category_name desc nulls last) = 1