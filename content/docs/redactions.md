+++
title = "Redactions"
weight = 6
+++

# Redactions

**Cargo Feature:** `redactions`

For all snapshots created based on `serde::Serialize` output `insta`
supports redactions.  This permits replacing values with hardcoded other
values to make snapshots stable when otherwise random or otherwise changing
values are involved.  Redactions are an optional feature and can be enabled
with the `redactions` feature.

For "redacting" strings you can use the [filters feature](../filters/) instead.

Redactions can be defined as the third argument to those assertion macros by
using the following syntax:

```rust
insta::assert_yaml_snapshot!(..., {
    "selector" => replacement_value
});
```

They can also be configured [via settings](../settings/).

## Selectors

The following selectors exist:

- `.key`: selects the given key
- `.$key`: indexes into the key of a collection.  This can be useful to redact compound keys.
- `["key"]`: alternative syntax for keys
- `[index]`: selects the given index in an array
- `[]`: selects all items on an array
- `[:end]`: selects all items up to `end` (excluding, supports negative indexing)
- `[start:]`: selects all items starting with `start`
- `[start:end]`: selects all items from `start` to `end` (end excluding,
  supports negative indexing).
- `.*`: selects all keys on that depth
- `.**`: performs a deep match (zero or more items).  Can only be used once.

## Static Redactions

This is an example of simple static assertions:

```rust
#[derive(Serialize)]
pub struct User {
    id: Uuid,
    username: String,
    extra: HashMap<String, String>,
}

insta::assert_yaml_snapshot!(&User {
    id: Uuid::new_v4(),
    username: "john_doe".to_string(),
    extra: {
        let mut map = HashMap::new();
        map.insert("ssn".to_string(), "123-123-123".to_string());
        map
    },
}, {
    ".id" => "[uuid]",
    ".extra.ssn" => "[ssn]"
});
```

## Dynamic Redactions

It's also possible to execute a callback that can produce a new value
instead of hardcoding a replacement value by using the
{{ api_link(item="dynamic_redaction", type="fn") }} function.  This function
can also be used to assert that a value follows a specific format before
redaction:

```rust
insta::assert_yaml_snapshot!(&User {
    id: Uuid::new_v4(),
    username: "john_doe".to_string(),
}, {
    ".id" => insta::dynamic_redaction(|value, _path| {
        // assert that the value looks like a uuid here
        assert_eq!(value
            .as_str()
            .unwrap()
            .chars()
            .filter(|&c| c == '-')
            .count(),
            4
        );
        "[uuid]"
    }),
});
```

The two arguments to the callback are of type {{ api_link(item="internals.Content", type="enum") }}
and {{ api_link(item="internals.ContentPath", type="struct") }}.  You can find
more information in the API documentation about how they work.

## Sorted Redactions

A special feature of the redaction support is the ability to sort a map or sequence at a selector.
This is particularly useful if you're working with a `HashSet` or something similar that has non
deterministic serialization order but you need to assert on it.  As `serde` does not let insta
distinguish between a vector and a set, no automatic ordering can be provided without causing issues
for the general case.

For sorted redactions you can use the {{ api_link(item="sorted_redaction", type="fn") }} function:

```rust
use std::collections::HashSet;
use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct User {
    id: u64,
    username: String,
    flags: HashSet<String>,
}

insta::assert_json_snapshot!(
    &User {
        id: 122,
        username: "jason_doe".to_string(),
        flags: vec!["zzz".into(), "foo".into(), "aha".into(), "is_admin".into()]
            .into_iter()
            .collect(),
    },
    {
        ".flags" => insta::sorted_redaction()
    }
);
```

## Rounded Redactions

For floating point values it can be useful to round them to certain number of decimal
places.  For this you can use the {{ api_link(item="rounded_redaction", type="fn") }} function:

```rust
use serde::Serialize;

#[derive(Debug, Serialize)]
pub struct Point {
    x: f64,
    y: f64,
}

insta::assert_json_snapshot!(
    &Point { x: 0.4223214, y: 0.424124 },
    {
        ".*" => insta::rounded_redaction(3)
    }
);
```
