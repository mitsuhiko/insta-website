{% set data = load_data(url="https://crates.io/api/v1/crates/" ~ crate, format="json") -%}
{{ data.crate.newest_version -}}
