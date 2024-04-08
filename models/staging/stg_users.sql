select
    $1:_id:"$oid",
    $1:active::boolean as is_active,
    $1:createdDate:"$date"::varchar::timestamp as created_timestamp,
    $1:role::varchar as role,
    $1:signUpSource::varchar as sign_up_source,
    $1:state::varchar as state,
    $1:lastLogin:"$date"::varchar::timestamp as last_login_timestamp
from
    {{ all_files('fetch_stage/users')}}