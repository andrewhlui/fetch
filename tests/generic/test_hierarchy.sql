{% test hierarchy(model, column_name, parent_column_name) %}

{# 
    Tests that a column is in a one-to-many or one-to-one relationship with another column.
    
#}

select
    {{ column_name }},
    count(distinct {{ parent_column_name }})

from {{ model }}
group by {{ column_name }}
having count(distinct {{ parent_column_name }}) > 1

{% endtest %}