+++
title = "Settings"
weight = 7
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
