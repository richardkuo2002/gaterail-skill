# Changelog

All notable changes to this project are documented here.

## [Unreleased]

README narrative rewrite (council review, 2026-10): moves the "Why"
pain-point section before the demo instead of after it, and rewrites the
comparison section to name hook-based enforcement tools as a real
alternative category instead of comparing only against a rules file and
an unrelated skill pile — repositions GateRail as solving the upstream
scope-agreement problem those tools don't touch, rather than as a weaker
version of them. No skill content, installer behavior, or technical
claims changed; translated READMEs had no equivalent sections to update.

Also fixes `check_docs_links.py`'s scan scope and gives it its own test
coverage. No skill content or installer behavior changed.

### Fixed

- `docs/*.md` and `examples/*/README.md` are now globbed instead of
  hand-maintained, matching how `.claude/skills/*/SKILL.md` and
  `.claude/references/*.md` were already discovered. A new doc or worked
  example is checked the moment it exists, instead of silently skipped
  until someone remembers to add it to the script's file list.

### Added

- `tests/test_check_docs_links.py`: unit tests for the doc-link checker
  itself, run in CI before it's used to validate the repo's own docs.

## [0.2.1] - 2026-09-21

New shared reference and compatibility documentation — closes both
near-term ROADMAP items. No existing skill behavior changed.

### Added

- `.claude/references/discovering-project-checks.md`: the concrete procedure
  behind every skill's "use the repository's own commands" — priority order
  of discovery sources (CI workflows first), verifying a command on the
  clean tree, and what "done" means in a repository with no checks. Linked
  from `definition-of-done.md` and the three skills that invoke repository
  commands; the installer now manages it as a third shared reference file.
- `docs/compatibility.md`: per-skill table of what stacks and CI providers
  the examples assume, what's exercised concretely in this repository vs.
  illustrative, and known gaps. Closes both near-term ROADMAP items.

## [0.2.0] - 2026-09-21

Plugin packaging and a second worked example — no skill content or
installer behavior changed.

### Added

- Claude Code plugin packaging: `.claude-plugin/plugin.json` and
  `.claude-plugin/marketplace.json`, so the repo installs directly via
  `/plugin marketplace add richardkuo2002/gaterail-skill` +
  `/plugin install gaterail@gaterail`. Skills load namespaced as
  `gaterail:<skill-name>`; the existing `.claude/skills/` layout and
  `install.sh` flow are unchanged.

- `examples/ts-cli/`: a second worked example, in TypeScript/Node instead
  of stdlib Python, showing the delivery gate exercising a real build
  (`tsc`) and type-check (`tsc --noEmit`) step, not just tests — the
  `examples/python-cli/` stack has no equivalent. Same request/spec/
  verification shape as `python-cli`, wired into CI as a new
  `example-tests-ts` job.

## [0.1.1] - 2026-09-08

Docs and test-coverage release — no skill or installer behavior changed.

### Added

- CI/license badges in `README.md`.
- `tests/test_install.sh`: scripted installer tests (fixed stdin, asserts on
  the resulting filesystem tree in a scratch directory), run in CI on every
  push. Replaces the manual-only checklist previously in `CONTRIBUTING.md`
  for install/dry-run/uninstall/decline-replace/unrelated-file-survives
  behavior.

## [0.1.0] - 2026-09-04

Initial public release, published as GitHub Release "GateRail v0.1.0" on
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
