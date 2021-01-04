{% if not crate %}{% set crate = config.extra.rust_crate %}{% endif %}
[`{{ item }}{% if type == "macro" %}!{% endif %}`](https://docs.rs/{{ crate }}/latest/{{ crate }}/{{ type }}.{{ item }}.html)