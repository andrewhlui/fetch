
select
    user_id,
    is_active,
    created_timestamp,
    role,
    sign_up_source,
    state,
    last_login_timestamp,
from
    {{ ref('int_users') }}