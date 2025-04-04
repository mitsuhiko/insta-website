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

And for an improved review experience it's recommended (but not necessary)
to install the `cargo-insta` tool:

Unix:

```
curl -LsSf https://insta.rs/install.sh | sh
```

Windows:

```
powershell -c "irm https://insta.rs/install.ps1 | iex"
```

For other options see [the CLI documentation](../cli/).

Note that this documentation prefers the YAML format which is why the `yaml`
feature is proposed by default.  If you do not want to use it, you can omit it.

## Optional: Faster Runs

Insta benefits from being compiled in release mode, even as dev dependency.  It
will compile slightly slower once, but use less memory, have faster diffs and
just generally be more fun to use.  To achieve that, opt `insta` and `similar`
(the diffing library) into higher optimization in your `Cargo.toml`:

```yaml
[profile.dev.package]
insta.opt-level = 3
similar.opt-level = 3
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
enable the `yaml` feature of insta.

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

## Tests without Insta

Note that `cargo-insta` is entirely optional.  You can also just use insta
directly from `cargo test` and control it via the `INSTA_UPDATE` environment
variable.  The default is `auto` which will write all new snapshots into
`.snap.new` files if no CI is detected so that `cargo-insta` can pick them
up.  The following other modes are possible:

- `auto`: the default. `no` for CI environments or `new` otherwise
- `always`: overwrites old snapshot files with new ones unasked
- `unseen`: behaves like `always` for new snapshots and `new` for others
- `new`: write new snapshots into `.snap.new` files
- `no`: does not update snapshot files at all (just runs tests)

You can for instance first run the tests and not write any new snapshots, and
if you like them run the tests again and update them:

```
INSTA_UPDATE=no cargo test
INSTA_UPDATE=always cargo test
```

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

## Annotating Snapshots

Particularly when reviewing a lot of snapshots, it can be hard to tell if a snapshot is correct
or not from the default information alone.  Out of the box, insta will include the expression that
was asserted on with the snapshot, but that is often insufficient.  Take for instance a practical
example from the MiniJinja template engine.  MiniJinja uses snapshots to assert the behavior of the
template engine.  Out of the box this is what ``cargo insta`` would show:

```
Reviewing [1/1] minijinja@0.20.0:
Snapshot file: minijinja/tests/snapshots/test_templates__vm@getattr.txt.snap
Snapshot: vm@getattr
Source: minijinja/tests/test_templates.rs:56
Input file: minijinja/tests/inputs/getattr.txt
──────────────────────────────────────────────────────────────────────────────────
template.render(ctx)
──────────────────────────────────────────────────────────────────────────────────
-old snapshot
+new results
────────────┬─────────────────────────────────────────────────────────────────────
    0       │-name: Peter
          0 │+name:
    1     1 │ active: true
────────────┴─────────────────────────────────────────────────────────────────────
```

It would be completely impossible for a reviewer to assess this snapshot without consulting the source code
of the assertion.  However by using {{ api_link(item="with_settings", type="macro") }} it is possible to
provide additional information in the form of a `description` (a text field) and `info` which is a
structured value.  The former takes a string, the latter a serializable value.

```rust
insta::with_settings!({
    info => &ctx, // the template context
    description => source, // the template source code
    omit_expression => true // do not include the default expression
}, {
    insta::assert_snapshot!(template.render(ctx));
});
```

With this modification, the review dialog in `cargo insta` looks like this now:

```
Reviewing [1/1] minijinja@0.20.0:
Snapshot file: minijinja/tests/snapshots/test_templates__vm@getattr.txt.snap
Snapshot: vm@getattr
Source: minijinja/tests/test_templates.rs:56
Input file: minijinja/tests/inputs/getattr.txt
──────────────────────────────────────────────────────────────────────────────────
name: {{ user.name }}
active: {{ user.is_active }}
──────────────────────────────────────────────────────────────────────────────────
user:
  is_active: true
  username: Peter
──────────────────────────────────────────────────────────────────────────────────
-old snapshot
+new results
────────────┬─────────────────────────────────────────────────────────────────────
    0       │-name: Peter
          0 │+name:
    1     1 │ active: true
────────────┴─────────────────────────────────────────────────────────────────────
```

Now it's more obvious about why the snapshot is failing and what it should be.  In this
case we can clearly see that there is a mismatch between `username` and `name` between
context and template.

## Continuous Integration

Insta behaves differently in CI environments.  For instance it will not
write new snapshot files.  This behavior is enabled by the `CI` environment
variable.  Please ensure that your CI system sets it.

```
export CI=true
```

