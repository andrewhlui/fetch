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
    {{ ref('int_brands') }}