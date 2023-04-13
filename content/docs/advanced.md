+++
title = "Advanced Features"
weight = 8
+++

# Advanced Features

Insta provides some advanced features for more complex test setups.  Some of
these require the activation of a cargo feature.

## Redactions

Redactions allow you to redact parts of the snapshot so that they are stable
even in the presence of non deterministic data such as timestamps or random
IDs.  See the [redactions documentation](../redactions/) for more information.

## Globbing

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

A three-argument version of this macro allows specifying a base directory
for the glob to start in. This allows globbing in arbitrary directories,
including parent directories:

```rust
use std::fs;

glob!("../test_data", "inputs/*.txt", |path| {
    let input = fs::read_to_string(path).unwrap();
    assert_snapshot!(input.to_uppercase());
});
```

### Filtering globs

If the `INSTA_GLOB_FILTER` environment variable is set, it is interpreted as
another glob matcher which glob included paths must match to be executed. This
is primarily useful for debugging, as it allows you to narrow your test execution
to just the snapshot you're interested in without pulling it into a separate test.

Multiple filters can be provided by separating them with a semicolon (`;`).
Filters can also be passed to `cargo insta test` via the `--glob-filter` option
which can be supplied multiple times.

## Custom Descriptions and Infos

Sometimes the information shown in the insta review screen is insufficient for
making decisions when reviewing.  Insta provides two additional flags that are
persisted in snapshot files: an `info` object and a `description` string.  Both
are show on the review screen.

Example:

```rust
#[derive(serde::Serialize)]
pub struct Info {
    env: HashMap<&'static str, &'static str>,
    cmdline: Vec<&'static str>,
}
let info = Info {
    env: From::from([("ENVIRONMENT", "production")]),
    cmdline: vec!["my-tool", "run"],
};

with_settings!({
    description => "The result from invoking my-tool run",
    info => &info
}, {
    assert_yaml_snapshot!(run_tool());
});
```

## Duplicates

By default insta will not allow snapshots to create duplicates.  There are
however situations where multiple runs should result in the same snapshot.
In that case you can use the {{ api_link(item="allow_duplicates", type="macro") }}
macro to change this behavior.  Wrap your assertions in it, and every assertion
will be compared against the one from the previous run:

```rust
insta::allow_duplicates! {
    for x in (0..10).step_by(2) {
        let is_even = x % 2 == 0;
        insta::assert_debug_snapshot!(is_even, @"true");
    }
}
```

## Test Output Control

Insta by default will output quite a lot of information as tests run.  For
instance it will print out all the diffs.  This can be controlled by setting
the `INSTA_OUTPUT` environment variable.  The following values are possible:

* `diff` (default): prints the diffs
* `summary`: prints only summaries (name of snapshot files etc.)
* `minimal`: like `summary` but more minimal
* `none`: insta will not output any extra information

## Disabling Assertion Failure

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

## Controlling Snapshot Updating

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

With `new` or `auto`, the `cargo-insta` command can be used
to review the snapshots conveniently.

## Handling Unused Snapshots

If we want to automatically check that there aren't unused snapshots in a
project, we can use the `--unreferenced` option:

```
cargo insta test --unreferenced=delete
```

Alternatively to deleting you can also set the `--unreferenced` flag to
`reject` or `warn` which will either fail or at least warn if there are
unused snapshots left.  When set to `auto` it behaves like `delete` locally
or like `reject` in a CI environment.

```
cargo insta test --unreferenced=auto
```

Note that this option is only helpful when running the full set of tests, since
insta does not control the execution of tests and can't assess whether unused
tests depend on the unreferenced snapshots.

## Workspace Root

By default insta will use the `cargo` binary to detect the workspace root. In
some situations this might not work. In that case you can export the
`INSTA_WORKSPACE_ROOT` environment variable and explicitly point insta to the
root of the workspace.
