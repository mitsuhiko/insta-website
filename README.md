# Insta Website

This is the website for the insta snapshotting tool.

It is built with [zola](https://www.getzola.org/).

The [changelog](https://insta.rs/changelog/) page loads `CHANGELOG.md` from
[`mitsuhiko/insta`](https://github.com/mitsuhiko/insta) at build time. The site
is redeployed on pushes to `main`, daily on a schedule, via `workflow_dispatch`,
or when the insta repo sends a `repository_dispatch` event (`sync-changelog`).
