{% macro create_format() %}

{% set format_sql %}
    create or replace file format json_gzip_format
        type = json
        compression = gzip 
        skip_header = 1
        empty_field_as_null = true
        field_optionally_enclosed_by = '"';
{% endset %}

{{ log('Beginning creation of file formats.') }}
{% set results = run_query(format_sql) %}
{{ log(results) }}

{% endmacro %}