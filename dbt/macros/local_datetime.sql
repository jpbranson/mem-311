{# UTC TIMESTAMP -> America/Chicago DATETIME #}
{% macro local_datetime(ts) -%}
    datetime({{ ts }}, '{{ var("local_tz") }}')
{%- endmacro %}
