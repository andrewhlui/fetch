{% test is_valid_date(model, column_name) %}

{# 
    Tests that a date or timestamp for our data is normal. 
#}

select
    {{ column_name }}

from {{ model }}

--not best practice to hardcode like this -- 
where
    {{ column_name }} between '2021-01-01' and '2024-04-08'

{% endtest %}