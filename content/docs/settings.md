+++
title = "Settings"
weight = 20
+++

# Settings

There are some settings that can be changed on a per-thread (and thus
per-test) basis.  These are documented in detail in the API docs of the
{{ api_link(item="Settings", type="struct") }} object.

Settings are always bound to a thread and some default settings are always
available.  These settings can be changed and influence how insta behaves on
that thread.  They can either temporarily or permanently changed.

Some of the settings can be changed but shouldn't as it will make it harder
for tools like cargo-insta or an editor integration to locate the snapshot
files.

Additionally some settings that influence how insta behaves in general can
be set in the `insta.yaml` config file.  For more information see [tool
config file](#tool-config-file).

## Configuration Basics

All available settings are documented as part of the main API documentation.
They can be reconfigured by setter (`set_SETTING_NAME`) on the [settings object]({{ api_link(item="Settings", type="struct", no_link=true) }}) or by field name (`SETTING_NAME`) when you use
the {{ api_link(item="with_settings", type="macro") }} macro.

### Configuration Macro

One rather convenient way to change the settings is to use the
{{ api_link(item="with_settings", type="macro") }} macro.  It lets you
reconfigure any setting for the duration of a block:

```rust
insta::with_settings!({sort_maps => true}, {
    // the tests here will force maps to sort
    insta::assert_json_snapshot!(some_map);
});
```

### Temporarily Rebinding

```rust
let mut settings = insta::Settings::clone_current();
settings.set_sort_maps(true);
settings.bind(|| {
    // the tests here will force maps to sort
    insta::assert_json_snapshot!(some_map);
});
```

## Settings as Building Blocks

While settings can be used to influence how Insta operates, they also act as
a building block for more complex test setups.  For instance the glob macro
internally is implemented by changing the settings on the file to provide
additional contextual information in the form of the current input file.

## Tool Config File

Insta (and by extension [`cargo-insta`](../cli/)) will look for a config file
in the following locations:

* `$CARGO_WORKSPACE/.config/insta.yaml`
* `$CARGO_WORKSPACE/insta.yaml`
* `$CARGO_WORKSPACE/.insta.yaml`

The files are tried in that order and the first that exists is loaded.  The file
is in YAML format.  Note that when this documentation refers to `behavior.force_update`
for instance it means that the key `force_update` is placed in the `behavior`
map:

```yaml
behavior:
  force_update: true
```

The following settings exist:

* `behavior.force_update`: this is the config option for the `INSTA_FORCE_UPDATE`
  environment variable.  If the environment variable is not set, this one is
  used.  Valid values are `true` and `false`, the default is `false`.
* `behavior.force_pass`: this is the config option for the `INSTA_FORCE_PASS`
  environment variable.  If the environment variable is not set, this one is
  used.  Valid values are `true` and `false`, the default is `false`.
* `behavior.output`: this is the config option for the `INSTA_OUTPUT`
  environment variable.  If the environment variable is not set, this one is
  use.  Valid values are `"diff"`, `"summary"`, `"minimal"` and `"none"`.
  The default is `"diff"`.
* `behavior.update`: this is the config option for the `INSTA_UPDATE`
  environment variable.  If the environment variable is not set, this one is
  used.  Valid values are `"auto"`, `"always"`, `"new"`, `"unseen"` and `"no"`.
  The default is `"auto"`. See [Controlling_Snapshot_Updating](/docs/advanced/#controlling-snapshot-updating) for details.
* `behavior.glob_fail_fast`: this is the config option for the `INSTA_GLOB_FAIL_FAST`
  environment variable.  If the environment variable is not set, this one is
  used.  Valid values are `true` and `false`, the default is `false`.
* `test.runner`: this is the config option for the `INSTA_TEST_RUNNER`
  environment variable.  If the environment variable is not set, this one is
  used.  Valid values are `"auto"`, `"cargo-test"`, `"nextest"`.  The default
  is `"auto"`. (note that at the moment `auto` always defaults to `cargo-test`).
* `test.auto_review`: when set to `true`, `cargo-insta` will automatically assume
  that the `--review` flag was passed unless a conflicting other option was passed.
  Defaults to `false`.
* `test.auto_accept_unseen`: when set to `true`, `cargo-insta` will automatically assume
  that the `--accept-unseen` flag was passed unless a conflicting other option was passed.
  Defaults to `false`.
* `review.include_ignored`: when set to `true`, `cargo-insta review` will behave
  as if `--include-ignored` is passed.
* `review.include_hidden`: when set to `true`, `cargo-insta review` will behave
  as if `--include-hidden` is passed.
* `review.warn_undiscovered`: when this is set to `false` the warning about undiscoverable
  snapshots is not shown.  Especially for large repositories creating this warning can
  take some time to execute.
