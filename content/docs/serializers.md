+++
title = "Serializers"
weight = 5
+++

# Serializers

The best supported snapshot experience is based on [serde](https://serde.rs/)
because it enables functionality such as redactions.  When you assert on serde
serializable types you can chose a variety of serialization formats.  The
example used for all of these is a list of two structs.

## Debug

This is the only serializer in insta that does not use `serde` behind the scenes
but instead uses the default `std::fmt::Debug` representation of a value.
Because this is not based on the `Serialize` trait this serializer does not
support redactions.  To use it use the {{ api_link(item="assert_debug_snapshot", type="macro") }}
macro:

```rust
insta::assert_debug_snapshot!(&user_list);
```

```javascript
[
    User(
        id: 1,
        email: "root@example.com",
        is_admin: true,
    ),
    User(
        id: 2,
        email: "user@example.com",
        is_admin: false,
    ),
]
```

It's generally recommended to use the [RON](#ron) serializer instead if redactions
are wanted.

## YAML

This serializer is available by default and the recommended one for most
situations.  It's available through the {{ api_link(item="assert_yaml_snapshot", type="macro") }}
macro:

```rust
insta::assert_yaml_snapshot!(&user_list);
```

```yaml
- id: 1
  email: root@example.com
  is_admin: true
- id: 2
  email: user@example.com
  is_admin: false
```

This serializer is recommended because YAML is human readable and excellent
at diffing because it is line based.

## JSON

This serializer is also available by default but usually not recommended.
It's available through the {{ api_link(item="assert_json_snapshot", type="macro") }}
macro:

```rust
insta::assert_json_snapshot!(&user_list);
```

```json
[
  {
    "id": 1,
    "email": "root@example.com",
    "is_admin": true
  },
  {
    "id": 2,
    "email": "user@example.com",
    "is_admin": false
  }
]
```

The JSON serializer is mainly useful if you are working with JSON APIs and you
want to serialize the responses exactly as they happen from the API.  However
JSON itself is not ideal for diffs which makes it slightly less nice to work
with compared to YAML.

There is also a second option that produces a compact (single line) snapshot if it fits there (up to 120 characters):

```rust
insta::assert_compact_json_snapshot!(&range);
```

```json
[1, 2, 3, 4, 5]
```

## TOML

[TOML](https://github.com/toml-lang/toml) is a serialization format which is
commonly used in configuration files.  It diffs well but unfortunately it cannot
represent all values that a serde serializer can produce.  As such it's not
enabled by default.

You need to activate it with the `toml` feature.  Once enabled it gives you
the {{ api_link(item="assert_toml_snapshot", type="macro") }} macro:

```rust
insta::assert_toml_snapshot!(&user_list_in_struct);
```

```toml
[[users]]
id = 1
email = 'root@example.com'
is_admin = true

[[users]]
id = 2
email = 'user@example.com'
is_admin = false
```

(Note that this example encloses the list in a top level struct as TOML
cannot support toplevel arrays.)

## RON

[RON](https://github.com/ron-rs/ron) is a serialization format that contains
Rust type names similar to `Debug`.  It's excellent if you also need to assert
on the types of values.

You need to activate it with the `ron` feature.  Once enabled it gives you
the {{ api_link(item="assert_ron_snapshot", type="macro") }} macro:

```rust
insta::assert_ron_snapshot!(&user_list);
```

```javascript
[
  User(
    id: 1,
    email: "root@example.com",
    is_admin: true,
  ),
  User(
    id: 2,
    email: "user@example.com",
    is_admin: false,
  ),
]
```

## CSV

[CSV](https://en.wikipedia.org/wiki/Comma-separated_values) is also available as
serialization format but it only works for some types of values.

You need to activate it with the `csv` feature.  Once enabled it gives you
the {{ api_link(item="assert_csv_snapshot", type="macro") }} macro:

```rust
insta::assert_csv_snapshot!(&user);
```

```csv
id,email,is_admin
1,root@example.com,true
```

(Note that this example uses a single item in the list as the CSV feature does
not yet support multiple values.)
