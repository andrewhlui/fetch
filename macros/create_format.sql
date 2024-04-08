{% macro create_format() %}

{% set format_sql %}
    create or replace file format json_gzip_format
        type = json
        compression = gzip;
{% endset %}

{{ log('Beginning creation of file formats.') }}
{% set results = run_query(format_sql) %}
{{ log(results) }}

{% endmacro %}