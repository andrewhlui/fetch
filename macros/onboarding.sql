{% macro onboarding() %}

{# 
    One-time macro meant to be run with `dbt run-operation` for the sake of onboarding. 
    Doesn't actually do everything (managing role permissions via DBT is a bad idea; no one would have ACCOUNTADMIN privs in a real work setting)
#}

{{ create_format() }}
{{ create_stage(
    stage_name = 'fetch', 
    integration_name = 'fetch', 
    file_format = 'csv_gzip_format'
    ) }}

{% endmacro %}