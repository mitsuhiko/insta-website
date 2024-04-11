+++
title = "Patterns"
weight = 30
+++

# Patterns

This is a collection of common patterns for how to best use Insta in some more complex
setups.

## rstest

If you are using the [rstest crate](https://crates.io/crates/rstest), more specifically the
`#[case]` feature you might want to use this pattern to ensure a pleasant experience.  Because
rstest will parametrize your tests insta will normally have challenges associating your
snapshots with the right parametrized test.  In that situation you can use the following macro
to add a suffix to your snapshot tests specific to your input values:

```rust
macro_rules! set_snapshot_suffix {
    ($($expr:expr),*) => {
        let mut settings = insta::Settings::clone_current();
        settings.set_snapshot_suffix(format!($($expr,)*));
        let _guard = settings.bind_to_scope();
    }
}
```

After that you can trivially set the snapshot suffix in your parametrized test:

```rust
#[rstest]
#[case(0, 2)]
#[case(2, 4)]
fn test_it(#[case] a: usize, #[case] b: usize) {
    set_snapshot_suffix!("{}-{}", a, b);
    insta::assert_debug_snapshot!(a * b);
}
```

In the above example the snapshots will then be named as follows:

```
tests/snapshots/example__it@0-2.snap
tests/snapshots/example__it@2-4.snap
```

## Uploading Snapshots from GitHub Actions

By default when running in a CI environment, insta won't generate new snapshot files.  When you
use GitHub Actions however you can upload build artifacts after the test run to download the
changed artifacts.  To accomplish this you need to force insta to write new snapshot files.

The following configuration forces files to be created and creates an artifact of all new
snapshot files.

```yaml
jobs:
  test:
    name: Snapshot Tests
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: dtolnay/rust-toolchain@master
        with:
          toolchain: stable
      - name: Test
        id: run_tests
        run: cargo test --all-features
        env:
          INSTA_UPDATE: new
      - name: Upload snapshots of failed tests
          if: ${{ failure() && steps.run_tests.outcome == 'failure' }}
          uses: actions/upload-artifact@v3
          with:
            name: failed-snapshots
            path: "**/snapshots/*.snap.new"
```
