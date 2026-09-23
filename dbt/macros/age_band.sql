{# Backlog age bands from the project plan; the numeric prefix keeps them sorted in visuals. #}
{% macro age_band(age_days) -%}
case
    when {{ age_days }} < 7 then '1. Under 7 days'
    when {{ age_days }} <= 30 then '2. 7-30 days'
    when {{ age_days }} <= 90 then '3. 31-90 days'
    when {{ age_days }} <= 180 then '4. 91-180 days'
    else '5. Over 180 days'
end
{%- endmacro %}
