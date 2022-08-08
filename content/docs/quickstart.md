+++
title = "Getting Started"
weight = 2
+++

# Getting Started

So you want to get started with snapshot testing?  Here is the 5 minute
introduction to how to be successful with insta.

## Installation

The recommended way is to add the dependency with `cargo add`:

```
cargo add --dev insta --features yaml
```

Alternatively edit your `Cargo.toml` manually and add `insta` as manual
dependency:

```toml
[dev-dependencies]
insta = { version = "{{ crate_version(crate="insta") }}", features = ["yaml"] }
```

And for an improved review experience it's recommended to install the
`cargo-insta` tool:

```
cargo install cargo-insta
```

Note that this documentation prefers the YAML format which is why the `yaml`
feature is proposed by default.  If you do not want to use it, you can omit it.

## Optional: Faster Runs

Insta benefits from being compiled in release mode, even as dev dependency.  It
will compile slightly slower once, but use less memory, have faster diffs and
just generally be more fun to use.  To achieve that, opt `insta` and `similar`
(the diffing library) into higher optimization in your `Cargo.toml`:

```yaml
[profile.dev.package.insta]
opt-level = 3

[profile.dev.package.similar]
opt-level = 3
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
  {{ api_link(item="assert_ron_snapshot", type="macro") }}, or {{ api_link(item="assert_csv_snapshot", type="macro") }}.
* You can instruct insta to use the `Debug` representation of a value by using
  {{ api_link(item="assert_debug_snapshot", type="macro") }}.

For most real world applications the recommendation is to use YAML snapshots
of serializable values.  This is because they look best under version control
and the diff viewer and support [redactions](../redactions/).  To use this
enabled the `yaml` feature of insta.

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

<div class="termcast"><img src="../quickstart.svg" alt=""></div>

You can run your tests as normal with `cargo test` but if you have multiple
snapshot assertions in a single function you might want to use `cargo insta
test` instead which collects all snapshot changes in one go.

```bash
cargo insta test
cargo insta review
```

The above can be combined into a single command as well:

```
cargo insta test --review
```

For more information see [cargo-insta](../cli/) documentation.

## Inline Snapshots

Snapshots can also be stored inline.  In that case the format
for the snapshot macros is `assert_snapshot!(reference_value, @"snapshot")`.
The leading at sign (`@`) indicates that the following string is the
reference value.  `cargo-insta` will then update that string with the new
value on review.

This is the example above with inline snapshots:

```rust
fn split_words(s: &str) -> Vec<&str> {
    s.split_whitespace().collect()
}

#[test]
fn test_split_words() {
    let words = split_words("hello from the other side");
    insta::assert_yaml_snapshot!(words, @"");
}
```

After the initial test failure you can run `cargo insta review` to
accept the change.  The file will then be updated automatically and the
reference value will be placed in the macro invocation like this:

```rust
fn split_words(s: &str) -> Vec<&str> {
    s.split_whitespace().collect()
}

#[test]
fn test_split_words() {
    let words = split_words("hello from the other side");
    insta::assert_yaml_snapshot!(words, @r###"
    ---
    - hello
    - from
    - the
    - other
    - side
    "###);
}
```
