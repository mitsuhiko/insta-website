+++
title = "Cargo Insta"
weight = 100
+++

# Cargo Insta

Cargo Insta is the companion command line tool to assist with snapshot reviewing.
It's not necessary for working with regular snapshots but it's required when
working with inline snapshots.

## Installation

Cargo Insta can be installed with `curl` to bash or powershell if you haven't yet.

On Unix (Linux and macOS):

```
curl -LsSf https://insta.rs/install.sh | sh
```

On Windows:

```
powershell -c "irm https://insta.rs/install.ps1 | iex"
```

Alternatively you can also manually install it with `cargo install`:

```
cargo install cargo-insta
```

You can also update it this way.  After installation it becomes available as `cargo insta`.

## Configuration

`cargo-insta` will load the `insta.yaml` config file from the workspace which
can be used to influence its behavior.  For more information on this have a look
[at the settings configuration](../settings/#tool-config-file).

## Commands

Cargo Insta comes with a few different commands.

**Common Options**

* `--color`: controls if colors should be used.  The default is auto detection (`auto`),
  alternative values are `always` and `none` to force colors on or off.
* `--manifest-path`: the path to the manifest file (`Cargo.toml`).  If not provided
  the workspace is auto discovered based on the current working directory.
* `--workspace-root`: this is an alternative to `--manifest-path` which lets you
  point insta directly at a workspace folder.  If this parameter is used the
  `Cargo.toml` file can be emitted in which case you can review snapshots that
  are placed outside of a rust package.
* `-e` / `--extensions`: lets you instruct cargo to consider other file extensions
  than `.snap`.  This is discouraged and should only be used in certain more
  advanced scenarios.
* `--include-ignored`: by default cargo insta will honor common ignore files such
  as `.gitignore` or `.ignore`.  When this flag is passed snapshots are also
  discovered if they would otherwise be ignored. (Legacy alias `--no-ignore`)
* `--include-hidden`: by default cargo will not walk hidden folders.  If this flag
  is provided then it will also walk into those.
* `-q` / `--quiet`: disables output on most commands.
* `--help`: outputs help information.
* `--snapshot`: when provided limits the operation to a single snapshot.  The
  argument must be the canonical snapshot name which is the absolute path to the
  snapshot file.  For inline snapshots it's the absolute path to the rust file
  with a colon and line number appended (eg: `/foo/bar.rs:42`).  This parameter
  can be provided multiple times.
* `--all`: tells Cargo Insta to operate on all packages in a crate.

### `review`

Review is the most important command as it can be used to review all pending
snapshots.  Pending snapshots are snapshots that changed from the stored
reference during a test run.

It scans for all non ignored snapshots (optionally filtered down to individual
snapshots with `--snapshot`) and then walks you through all of them.  For each
snapshot change a diff is shown.  To accept a snapshot change press `a`, to
reject `r` and to skip for now use `s`.  Diffs can be turned on and off with `d`
and auxiliary information can be shown or hidden with `i`.

<img src="../review.png" class="snap" alt="screenshot of cargo-insta review">

When you skip the new snapshot file will be left behind.

### `accept`

This operates exactly like `review` but instead of an interactive review
all snapshot changes will be accepted.

### `reject`

This operates exactly like `review` but instead of an interactive review
all snapshot changes will be rejected.

### `pending-snapshots`

This command returns a list of all snapshots that need reviewing.  This is
useful when you want to provide editor integrations for insta.  For instance
this is how the VS Code extension shows the list of pending snapshots.

When JSON output is used the old and new contents of inline snapshots are
also returned.

**Options:**

* `--as-json`: output the value as JSON instead of human readable.

### `test`

The test command lets you execute all tests (similar to `cargo test`) but
forces all snapshot tests to pass so that they are collected.  It accepts
the same arguments as the normal `cargo test` command.

Additionally extra comments can be passed to `cargo test` when separated
with `--`.

**Options:**

* `-p` / `--package`: selects the package to run tests for.
* `--no-force-pass`: disables the default behavior that forces all snapshot
  tests to pass.
* `--features`: space-separated list of features to activate.
* `--all-features`: activate all available features
* `--no-default-features`: do not activate the `default` feature
* `--review`: automatically follow up with snapshot review after test run.
* `--accept`: automatically accept all snapshots after test run.
* `--accept-unseen`: like `--accept` but only accept all new (previously unseen) snapshots.
* `--keep-pending`: do not reject pending snapshots before run.
* `--force-update-snapshots`: update all snapshots even if they are still matching.  This is useful if insta changed the metadata format.
* `--unreferenced`: controls what should happen with unreferenced snapshots.  The default
  is `ignore`. Valid values are `ignore`, `warn`, `reject`, `delete` and `auto`.
  `warn` will emit a warning if there are unreference snapshots, `reject` will
  error. `delete` will delete unreferenced snapshots after the test run.  Finally
  `auto` behaves like `reject` in CI and like `delete` if not run from CI.
* `--glob-filter`: Filters to apply to the insta glob feature
* `--test-runner`: Selects a different test runner (`cargo-test` or `nextest`)

Some other options are directly mirrored from `cargo test`.
