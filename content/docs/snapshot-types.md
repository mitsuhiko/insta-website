+++
title = "Snapshot Types"
weight = 4
+++

# Snapshot Types

Insta has two major types of snapshots: named and inline snapshots.  The former
are placed as `.snap` files in the `snapshots` folder, the latter are stored
inline in string literals in the `.rs` files.

## Implicitly Named Snapshots

All snapshot assertion functions let you leave out the snapshot name in
which case the snapshot name is derived from the test name (with an optional
leading `test_` prefix removed.

This works because the rust test runner names the thread by the test name
and the name is taken from the thread name.  In case your test spawns additional
threads this will not work and you will need to provide a name explicitly.
There are some situations in which rust test does not name or use threads.
In these cases insta will panic with an error.  The `backtrace` feature can
be enabled in which case insta will attempt to recover the test name from
the backtrace.

These are two assertions that use implicitly named snapshots:

```rust
#[test]
fn test_something() {
    assert_snapshot!("first value");
    assert_snapshot!("second value");
}
```

This creats two snapshots named `something` and `somethign-2`.

## Named snapshots

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

## Inline Snapshots

Snapshots can also be stored inline.  In that case the format
for the snapshot macros is `assert_snapshot!(reference_value, @"snapshot")`.
The leading at sign (`@`) indicates that the following string is the
reference value.  `cargo-insta` will then update that string with the new
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
accept the change.  The file will then be updated automatically and the
reference value will be placed in the macro invocation.  Note that inline
snapshots require the use of `cargo-insta`.