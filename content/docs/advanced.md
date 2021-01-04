+++
title = "Advanced Features"
weight = 6
+++

# Advanced Features

Insta provides some advanced features for more complex test setups.  Some of
these require the activation of a cargo feature.

## Redactions

**Cargo Feature:** `redactions`

For all snapshots created based on `serde::Serialize` output `insta`
supports redactions.  This permits replacing values with hardcoded other
values to make snapshots stable when otherwise random or otherwise changing
values are involved.  Redactions are an optional feature and can be enabled
with the `redactions` feature.

Redactions can be defined as the third argument to those macros with
the syntax `{ selector => replacement_value }`.

The following selectors exist:

- `.key`: selects the given key
- `["key"]`: alternative syntax for keys
- `[index]`: selects the given index in an array
- `[]`: selects all items on an array
- `[:end]`: selects all items up to `end` (excluding, supports negative indexing)
- `[start:]`: selects all items starting with `start`
- `[start:end]`: selects all items from `start` to `end` (end excluding,
  supports negative indexing).
- `.*`: selects all keys on that depth
- `.**`: performs a deep match (zero or more items).  Can only be used once.

Example usage:

```rust
#[derive(Serialize)]
pub struct User {
    id: Uuid,
    username: String,
    extra: HashMap<String, String>,
}

assert_yaml_snapshot!(&User {
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

It's also possible to execute a callback that can produce a new value
instead of hardcoding a replacement value by using the
{{ api_link(item="dynamic_redaction", type="fn") }} function:

```rust
assert_yaml_snapshot!(&User {
    id: Uuid::new_v4(),
    username: "john_doe".to_string(),
}, {
    ".id" => dynamic_redaction(|value, _| {
        // assert that the value looks like a uuid here
        "[uuid]"
    }),
});
```

## Globbing

**Cargo Feature:** `glob`

Sometimes it can be useful to run code against multiple input files.
The easiest way to accomplish this is to use the {{ api_link(item="glob", type="macro") }}
macro which runs a closure for each input path that matches. Before the
closure is executed the settings are updated to set a reference to the input
file and the appropriate snapshot suffix. Globbing is an optional feature and
can be enabled with the `glob` feature

Example:

```rust
use std::fs;

glob!("inputs/*.txt", |path| {
    let input = fs::read_to_string(path).unwrap();
    assert_json_snapshot!(input.to_uppercase());
});
```

The path to the glob macro is relative to the location of the test
file.  It uses the `globset` crate for actual glob operations.
