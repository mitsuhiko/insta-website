+++
title = "Advanced Features"
weight = 7
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

## Test Output Control

Insta by default will output quite a lot of information as tests run.  For
instance it will print out all the diffs.  This can be controlled by setting
the `INSTA_OUTPUT` environment variable.  The following values are possible:

* `diff` (default): prints the diffs
* `summary`: prints only summaries (name of snapshot files etc.)
* `minimal`: like `summary` but more minimal
* `none`: insta will not output any extra information

## Deleting Unused Snapshots

Insta only has limited support for detecting unused snapshot files.  The
reason for this is that insta does not control the execution of all tests
so it cannot spot which files are actually unreferenced.

There are two solutions for this problem.  One is to use `cargo-insta`'s
`test` command which accepts a `--delete-unreferenced-snapshots` flag:

```text
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