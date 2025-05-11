+++
title = "Testing CLIs"
weight = 9
+++

# Testing CLIs

There is an extension module to insta called [`insta-cmd`](https://github.com/mitsuhiko/insta-cmd)
which allows to you to easily test command line applications.

## Basics

The two most important APIs in `insta_cmd` are
[`assert_cmd_snapshot`](https://docs.rs/insta-cmd/latest/insta_cmd/macro.assert_cmd_snapshot.html)
and
[`get_cargo_bin`](https://docs.rs/insta-cmd/latest/insta_cmd/fn.get_cargo_bin.html).  The
first is macro which lets you assert the output of a [`Command`](https://doc.rust-lang.org/std/process/struct.Command.html).  The latter is a function that returns the path to a binary (the one from your crate).

In the most basic example you would end up with something like this:

```rust
use std::process::Command;
use insta_cmd::{assert_cmd_snapshot, get_cargo_bin};

fn cli() -> Command {
    Command::new(get_cargo_bin("my-executable"))
}

#[test]
fn test_version() {
    assert_cmd_snapshot!(cli().arg("--version"), @r###"
    success: true
    exit_code: 0
    ----- stdout -----
    my-executable 1.0.0

    ----- stderr -----
    "###);
}
```

## Passing Stdin

For when your application uses stdin, you can use the magic `pass_stdin` method that is
also available within the macro:

```rust
use std::process::Command;
use insta_cmd::{assert_cmd_snapshot, get_cargo_bin};

fn cli() -> Command {
    Command::new(get_cargo_bin("my-executable"))
}

#[test]
fn test_echo_back() {
    assert_cmd_snapshot!(cli().arg("echo-back").pass_stdin("Hello World!"), @r###"
    success: true
    exit_code: 0
    ----- stdout -----
    Hello World!

    ----- stderr -----
    "###);
}
```

## Filtering

The most important aspect when working with command line tools is to use the `filters`
feature to redact output.  This is because many command line tools use paths and other
things that make it otherwise hard to snapshot.  It's recommended to use a reusable macro
to normalize this.  Here an example of some filters:

```rust
macro_rules! apply_common_filters {
    {} => {
        let mut settings = insta::Settings::clone_current();
        // Macos Temp Folder
        settings.add_filter(r"/var/folders/\S+?/T/\S+", "[TEMP_FILE]");
        // Linux Temp Folder
        settings.add_filter(r"/tmp/\.tmp\S+", "[TEMP_FILE]");
        // Windows Temp folder
        settings.add_filter(r"\b[A-Z]:\\.*\\Local\\Temp\\\S+", "[TEMP_FILE]");
        // Convert windows paths to Unix Paths.
        settings.add_filter(r"\\\\?([\w\d.])", "/$1");
        let _bound = settings.bind_to_scope();
    }
}
```

And then you can use it as such:

```rust
#[test]
fn test_basic() {
    apply_common_filters!();
    assert_cmd_snapshot!(cli().arg("create-temp-file").arg("--template=./foo"), @r###"
    success: true
    exit_code: 0
    ----- stdout -----
    Created temp file in [TEMP_FILE]
    Template file: ./foo

    ----- stderr -----
    "###);
}
```

## Examples

If you want to be inspired, have a look at the following projects for some ideas:

- `rye`: [rye tests](https://github.com/astral-sh/rye/tree/main/rye/tests)
- `minijinja`: [minijinja-cli tests](https://github.com/mitsuhiko/minijinja/blob/main/minijinja-cli/tests/test_basic.rs)
