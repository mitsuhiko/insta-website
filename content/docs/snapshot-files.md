+++
title = "Snapshot Files"
weight = 5
+++

# Snapshot Files

The committed snapshot files will have a header with some meta information
that can make debugging easier and the snapshot.  The file extension for
snapshot files is `.snap` if they are comitted or `.snap.new` if they are
pending.  Header and snapshot are separated by a triple dashes (`---`).  Since
the header is YAML itself it also starts with triple dashes (`---`).  This format
is similar to front-matter in Markdown.

## Example File

```yaml
---
expression: "vec![1, 2, 3]"
source: tests/test_basic.rs
---
[
    1,
    2,
    3
]
```

## Header Fields

The header of the file is always in YAML format.

The following fields exist in the header:

* `expression`: This is the stringified expression that was passed to the
  assertion macro.  `cargo-insta` will typically attempt to reformat this with
  `rustfmt` so it becomes more readable.
* `source`: this is the workspace relative path to the file which contained
  the snapshot assertion.
* `input_file`: when [globs](../advanced/#globbing) are used this refers to the
  file which was the input for the snapshot.

## Snapshot Body

The body is always in whatever format [was serialized](../serializers/). This
can be YAML, JSON or anything else.  Syntax highlighters should be liberal here
and assume a variation of YAML and RON.

## Newlines

Snapshot files are normalized to unix newlines (LF) before diffing and will always
be generated with unix newlines when saving.
