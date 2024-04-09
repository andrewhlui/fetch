{% macro generate_comparison(model_a, model_b, attributes, measure)%}

{# 
    Generates a comparison between two models. Useful for testing.
#}

with cte_a as (
select
{% for attribute in attributes %}
    {{ attribute }},
{% endfor %}
    --in prod setting would include aggregation type as parameter, measure would be measures and would be dictionary
    sum({{ measure }}) as {{ measure }}
from
    {{ model_a }}
group by all
), 

cte_b as (
select
{% for attribute in attributes %}
    {{ attribute }},
{% endfor %}
    sum({{ measure }}) as {{ measure }}
from
    {{ model_b }}
group by all
)

select
    {% for attribute in attributes %}
    coalesce(cte_a.{{ attribute }}, cte_b.{{ attribute }}) as {{ attribute }},
    {% endfor %}
    cte_a.{{ measure }} as a_{{ measure }},
    cte_b.{{ measure }} as b_{{ measure }},
from
    cte_a 
full outer join cte_b 
    on 
    {% for attribute in attributes %}
        cte_a.{{ attribute }} = cte_b.{{ attribute }} {% if not loop.last %} and {% endif %}
    {% endfor %}
where a_{{ measure }} != b_{{ measure }}

{% endmacro %}