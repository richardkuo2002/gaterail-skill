# Changelog

All notable changes to this project are documented here.

This project has not yet made a tagged release; nothing below is published
as a version. Entries move out of Unreleased into a version section only
when a matching Git tag / GitHub Release is created.

## Unreleased

### Added

- Seven Claude Code skills: `spec-driven-development`,
  `planning-and-task-breakdown`, `api-and-interface-design`,
  `incremental-implementation`, `test-driven-development`,
  `ci-cd-and-automation`, `git-workflow-and-versioning`.
- Shared references backing the delivery gate:
  `.claude/references/definition-of-done.md` and
  `.claude/references/testing-patterns.md`.
- Interactive installer (`install.sh`) with `--dry-run` and `--uninstall`,
  confirmation before replacing an already-installed skill, and preservation
  of unrelated files in an existing `references/` directory.
- Runnable example (`examples/python-cli/`) demonstrating the specification
  and delivery/verification gates on a small, real change.
- CI: skill-frontmatter validation, `install.sh` syntax check, internal
  link/path validation, and the example's test suite.
- `CONTRIBUTING.md`, `SECURITY.md`, `ROADMAP.md`, issue and pull request
  templates.
- README rewritten around the two-gate workflow model, with matching updates
  to the zh-TW, ja, and ko translations.
