+++
title = "Filters"
weight = 7
+++

# Filters

**Cargo Feature:** `filters`

Similar to [redactions](../redactions/) insta also supports filtering of snapshots.
These are regular expressions applied to the actual snapshot content to normalize
input before they are persisted to disk. Filters are an optional feature and
can be enabled with the `filters` feature.

Filters can be only defined via settings. They are individually added with
`Settings::add_filter` or by using the `with_settings!` macro. The first argument
is the regex, the second is the replacement string. When set with `with_settings!`
a vector of tuples is expected:

```rust
insta::with_settings!({filters => vec![
    (r"\b[[:xdigit:]]{32}\b", "[UID]"),
]}, {
    insta::assert_snapshot!(...);
});
```

Filters are useful when redactions cannot be used because the snapshot is inherently
in a string format.
