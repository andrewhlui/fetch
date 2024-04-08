
select
    user_id,
    is_active,
    created_timestamp,
    user_role,
    sign_up_source,
    state,
    last_login_timestamp,
from
    {{ ref('int_users') }}