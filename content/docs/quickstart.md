+++
title = "Getting Started"
weight = 2
+++

# Getting Started

So you want to get started with snapshot testing?  Here is the 5 minute
introduction to how to be successful with insta.

## Installation

The recommended way is to add the dependency with `cargo-edit` if you have it:

```
cargo add --dev insta
```

Alternatively edit your `Cargo.toml` manually and add `insta` as manual
dependency:

```toml
[dev-dependencies]
insta = "{{ crate_version(crate="insta") }}"
```

And for an improved review experience it's recommended to install the
`cargo-insta` tool:

```
cargo install cargo-insta
```

## Writing Tests

Insta snapshots reference values which are fundamentally strings.  However the
method by which these strings are generated can be split in three different
ways:

* You can stringify a reference value yourself and assert on it with
  {{ api_link(item="assert_snapshot", type="macro") }}.
* You can have insta serialize a `serde::Serialize`able value into a string by
  using one of the following macros: {{ api_link(item="assert_json_snapshot", type="macro") }},
  {{ api_link(item="assert_yaml_snapshot", type="macro") }},
  {{ api_link(item="assert_toml_snapshot", type="macro") }},
  {{ api_link(item="assert_ron_snapshot", type="macro") }}, or
  {{ api_link(item="assert_csv_snapshot", type="macro") }}.
* You can instruct insta to use the `Debug` representation of a value by using
  {{ api_link(item="assert_debug_snapshot", type="macro") }}.

For most real world applications the recommendation is to use YAML snapshots
of serializable values.  This is because they look best under version control
and the diff viewer and support [redactions](#redactions).

The following example demonstrates a very simple test case:

```rust
fn split_words(s: &str) -> Vec<&str> {
    s.split_whitespace().collect()
}

#[test]
fn test_split_words() {
    let words = split_words("hello from the other side");
    insta::assert_yaml_snapshot!(words);
}
```

## Reviewing Snapshots

The recommended flow is to run the tests once, have them fail and check if the
result is okay.  By default the new snapshots are stored next to the old ones
with the extra `.new` extension.  Once you are satisifed move the new files
over.  To simplify this workflow you can use cargo insta review which will let
you interactively review them:

```bash
cargo insta review
```

For more information see [cargo-insta](../cli/) documentation.

## Snapshot Updating

During test runs snapshots will be updated according to the `INSTA_UPDATE`
environment variable.  The default is `auto` which will write all new
snapshots into `.snap.new` files if no CI is detected so that `cargo-insta`
can pick them up.  Normally you don't have to change this variable.

`INSTA_UPDATE` modes:

- `auto`: the default. `no` for CI environments or `new` otherwise
- `always`: overwrites old snapshot files with new ones unasked
- `unseen`: behaves like `always` for new snapshots and `new` for others
- `new`: write new snapshots into `.snap.new` files
- `no`: does not update snapshot files at all (just runs tests)

When `new` or `auto` is used as mode the `cargo-insta` command can be used
to review the snapshots conveniently.

## Test Assertions

By default the tests will fail when the snapshot assertion fails.  However
if a test produces more than one snapshot it can be useful to force a test
to pass so that all new snapshots are created in one go.

This can be enabled by setting `INSTA_FORCE_PASS` to `1`:

```
INSTA_FORCE_PASS=1 cargo test --no-fail-fast
```

A better way to do this is to run `cargo insta test --review` which will
run all tests with force pass and then bring up the review tool:

```
cargo insta test --review
```