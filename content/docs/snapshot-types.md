+++
title = "Snapshot Types"
weight = 4
+++

# Snapshot types

Insta has two major types of snapshots: file and inline snapshots. The former
are placed as separate `.snap` files, the latter are stored inline in string
literals in the `.rs` files.

File snapshots are stored in the `snapshots` folder right next to the test file
where this is used. The name of the file is `<module>__<name>.snap` where
the `name` of the snapshot. Snapshots can either be explicitly named or the
name is derived from the test name.

The format of snapshot files [is documented here](../snapshot-files/).

## File snapshots

### Unnamed snapshots

All snapshot assertion functions let you leave out the snapshot name in which
case the snapshot name is derived from the function name (with an optional
leading `test_` prefix removed, as it is typically the test name).

These are two assertions that use implicitly named snapshots:

```rust
#[test]
fn test_something() {
    assert_snapshot!("first value");
    assert_snapshot!("second value");
}
```

This creates two snapshots named `something` and `something-2`.

### Named snapshots

Explicit snapshot naming can be useful to be more explicit when multiple
snapshots are tested within one function as the default behavior would be to
just count up the snapshot names.

To provide an explicit name provide the name of the snapshot as first
argument to the macro:

```rust
#[test]
fn test_something() {
    assert_snapshot!("first_snapshot", "first value");
    assert_snapshot!("second_snapshot", "second value");
}
```

This will create two snapshots: `first_snapshot` for the first value and
`second_snapshot` for the second value.

## Inline snapshots

Snapshots can also be stored inline. In that case the format
for the snapshot macros is `assert_snapshot!(reference_value, @"snapshot")`.
The leading at sign (`@`) indicates that the following string is the
reference value. `cargo-insta` will then update that string with the new
value on review:

```rust
#[derive(Serialize)]
pub struct User {
    username: String,
}

assert_yaml_snapshot!(User {
    username: "john_doe".to_string(),
}, @"");
```

After the initial test failure you can run `cargo insta review` to
accept the change. The file will then be updated automatically and the
reference value will be placed in the macro invocation. Note that inline
snapshots require the use of `cargo-insta`.

## Debug expressions

Snapshots optionally accept a debug expression, which can be helpful for adding
contextual information to the snapshot. Where this isn't provided, insta
defaults to the stringified expression.

```rust
#[test]
fn test_something() {
    // Will use tha value of `description_of_1`
    assert_snapshot!("snapshot", description_of_1, expr_1);
    // No debug expr — will use the literal `"expr_1"` as the debug expr
    assert_snapshot!("snapshot_no_debug", expr_1);
}
```

## Snapshot types list

Here's a full list of formats that snapshots macros accept:

| Snapshot type                     | Example                                                                   |
| --------------------------------- | ------------------------------------------------------------------------- |
| File, named                       | `assert_snapshot!("name", expr)`                                          |
| File, named, debug expr           | `assert_snapshot!("name", expr, "description")`                           |
| File, unnamed                     | `assert_snapshot!(expr)`                                                  |
| File, redacted, named             | `assert_yaml_snapshot!("name", expr, {"." => sorted_redaction()})`        |
| File, redacted, named, debug expr | `assert_yaml_snapshot!(expr, {"." => sorted_redaction()}, "description")` |
| File, redacted, unnamed           | `assert_yaml_snapshot!(expr, {"." => sorted_redaction()})`                |
| Inline                            | `assert_snapshot!(expr, @"result")`                                       |
| Inline, redacted                  | `assert_snapshot!(expr, {"." => sorted_redaction()}, @"result")`          |
