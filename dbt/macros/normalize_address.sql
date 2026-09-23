{#
  Phase A address standardization (see docs/methodology.md, "Location matching").
  Returns the house-number + street form: a leading business/place name dropped when a house-number segment
  follows it, then uppercase, city/state/ZIP, unit designators and punctuation removed,
  street types and directionals abbreviated, a leading house-number range reduced to its first number.
#}
{% macro normalize_address(col) -%}
{#- Jinja string literals decode escapes, so every regex backslash is written doubled. -#}
{%- set steps = [
    ("^[^0-9,][^,]*,\\s*(\\d+\\s[^,]*)", "\\\\1"),
    (",.*$", ""),
    ("\\s(APT|UNIT|STE|SUITE|BLDG|LOT)\\b.*$|\\s*#.*$", ""),
    ("^(\\d+)\\s*-\\s*\\d+\\b", "\\\\1"),
    ("[^A-Z0-9 ]", " "),
    ("\\s+", " "),
] -%}
{%- set abbreviations = [
    ('STREET', 'ST'), ('AVENUE', 'AVE'), ('AV', 'AVE'), ('ROAD', 'RD'), ('DRIVE', 'DR'), ('BOULEVARD', 'BLVD'),
    ('LANE', 'LN'), ('COVE', 'CV'), ('CIRCLE', 'CIR'), ('PARKWAY', 'PKWY'), ('PLACE', 'PL'), ('COURT', 'CT'),
    ('TERRACE', 'TER'), ('HIGHWAY', 'HWY'), ('TRAIL', 'TRL'), ('EXTENDED', 'EXT'), ('EXTENSION', 'EXT'),
    ('SQUARE', 'SQ'), ('CROSSING', 'XING'), ('POINT', 'PT'), ('ALLEY', 'ALY'),
    ('NORTH', 'N'), ('SOUTH', 'S'), ('EAST', 'E'), ('WEST', 'W')
] -%}
{%- set ns = namespace(expr="upper(coalesce(" ~ col ~ ", ''))") -%}
{%- for pattern, repl in steps -%}
    {%- set ns.expr = "regexp_replace(" ~ ns.expr ~ ", r'" ~ pattern ~ "', '" ~ repl ~ "')" -%}
{%- endfor -%}
{%- for long, short in abbreviations -%}
    {%- set ns.expr = "regexp_replace(" ~ ns.expr ~ ", r'\\b" ~ long ~ "\\b', '" ~ short ~ "')" -%}
{%- endfor -%}
trim({{ ns.expr }})
{%- endmacro %}

{#
  Matching key: normalized address without a trailing street-type token, only when it starts with a
  non-zero house number. "2785 CLAUDETTE" and "2785 CLAUDETTE RD" share a key; "0 WINCHESTER RD" and
  "WALKER AVE" get none (D23).
#}
{% macro address_key(normalized_col) -%}
if(regexp_contains({{ normalized_col }}, r'^[1-9]\d* [A-Z0-9]'),
   regexp_replace({{ normalized_col }},
       r' (ST|AVE|RD|DR|BLVD|LN|CV|CIR|PKWY|PL|CT|TER|HWY|TRL|WAY|SQ|XING|PT|ALY|LOOP|PASS|RUN|PATH|WALK|ROW|PIKE|PLZ|CTR)( EXT)?$', ''),
   null)
{%- endmacro %}
