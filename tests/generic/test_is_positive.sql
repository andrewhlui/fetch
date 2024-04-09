{% test is_positive(model, column_name) %}

{# 
    Tests that something is higher than 0.
#}

select
    {{ column_name }}

from {{ model }}

where
    {{ column_name }} <= 0

{% endtest %}