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

### Filtering globs

If the `INSTA_GLOB_FILTER` environment variable is set, it is interpreted as
another glob matcher which glob included paths must match to be executed. This
is primarily useful for debugging, as it allows you to narrow your test execution
to just the snapshot you're interested in without pulling it into a separate test.

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

When `new` or `auto` is used as mode the `cargo-insta` command can be used
to review the snapshots conveniently.

## Deleting Unused Snapshots

Insta only has limited support for detecting unused snapshot files.  The
reason for this is that insta does not control the execution of all tests
so it cannot spot which files are actually unreferenced.

There are two solutions for this problem.  One is to use `cargo-insta`'s
`test` command which accepts a `--delete-unreferenced-snapshots` flag:

```
cargo insta test --delete-unreferenced-snapshots
```

The second option is to use the `INSTA_SNAPSHOT_REFERENCES_FILE` environment
variable to instruct insta to append all referenced files into a list.  This
can then be used to delete all files not referenced.  For instance one could
use [ripgrep](https://github.com/BurntSushi/ripgrep) like this:

```bash
export INSTA_SNAPSHOT_REFERENCES_FILE="$(mktemp)"
cargo test
rg --files -lg '*.snap' "$(pwd)" | grep -vFf "$INSTA_SNAPSHOT_REFERENCES_FILE" | xargs rm
rm -f $INSTA_SNAPSHOT_REFERENCES_FILE
```

## Workspace Root

By default insta will use the `cargo` binary to detect the workspace root. In
some situations this might not work. In that case you can export the
`INSTA_WORKSPACE_ROOT` environment variable and explicitly point insta to the
root of the workspace.
