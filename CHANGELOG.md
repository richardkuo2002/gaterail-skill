# Changelog

All notable changes to this project are documented here.

## Unreleased

No unreleased changes yet.

## [0.1.0] - 2026-09-04

Initial public release. Tagged `v0.1.0` (annotated tag, message
`GateRail v0.1.0`) and published as GitHub Release "GateRail v0.1.0" on
`main`, after the root CI workflow succeeded (`validate-skills` and
`example-tests`).

### Added

- Seven composable Claude Code workflow skills: `spec-driven-development`,
  `planning-and-task-breakdown`, `api-and-interface-design`,
  `incremental-implementation`, `test-driven-development`,
  `ci-cd-and-automation`, `git-workflow-and-versioning`.
- Specification-gate workflow guidance across the first three skills above.
- Delivery/verification-gate workflow guidance across the remaining four,
  including the shared references backing them:
  `.claude/references/definition-of-done.md` and
  `.claude/references/testing-patterns.md`.
- Interactive installer (`install.sh`) with project-level and global
  install, safe overwrite confirmation, `--dry-run`, and scoped
  `--uninstall`.
- Runnable example (`examples/python-cli/`), a standard-library-only Python
  CLI demonstrating the specification and delivery/verification gates on a
  small, real change.
- Root CI validation for skill frontmatter, `install.sh` shell syntax,
  documentation paths/links, and the example's test suite.
- README documentation in English, Traditional Chinese, Japanese, and
  Korean.
- MIT license, `CONTRIBUTING.md`, `SECURITY.md`, `ROADMAP.md`, issue and
  pull request templates.
