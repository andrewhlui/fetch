select
    $1:_id:"$oid"::varchar as brand_id,
    $1:barcode::varchar as barcode,
    $1:cpg:"$id":"$oid"::varchar as cpg_id,
    $1:cpg:"$ref"::varchar as cpg_ref,
    $1:name::varchar as brand_name,
    $1:category::varchar as category_name,
    $1:brandCode::varchar as brand_code,
    $1:topBrand::varchar as is_top_brand,
    $1:categoryCode::varchar as category_code
from
    {{ all_files('fetch_stage/brands') }}