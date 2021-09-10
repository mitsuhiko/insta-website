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
