# Roadmap

No dates. Items move here when there's a concrete next step, and out when
they're done or dropped.

## Near-term (committed direction)

- **Installer tests.** `install.sh` is currently verified by manual exercise
  (see `CONTRIBUTING.md`) plus `bash -n` in CI. A scripted test harness
  (feeding fixed stdin, asserting on the resulting filesystem tree in a
  scratch directory) would catch regressions without a human running the
  manual checklist every time.
- **Additional example repositories.** `examples/python-cli/` covers one
  stack (stdlib Python, `unittest`). A second example in a different
  ecosystem (e.g. a stack with a real linter/type-checker/build step) would
  show the delivery gate exercising checks beyond "tests pass."
- **Clearer compatibility coverage.** Document, per skill, what stacks and
  CI providers its examples assume, and where the guidance is intentionally
  generic vs. where it's been exercised concretely.
- **Integration patterns for repository-defined checks.** Right now each
  skill tells the agent to "use the repository's own commands." A short,
  concrete guide for how to make those commands discoverable (e.g. where to
  look, what to do when none exist yet) would reduce ambiguity.

## Exploration (not committed)

- Support patterns for coding agents other than Claude Code, where the
  underlying skill content could transfer even if the loading mechanism
  differs.
- Using repository history (commit messages, past PR descriptions) as
  evidence during the specification gate, instead of relying only on the
  current conversation.
- Reusable CI adapters — shared workflow snippets for common stacks that a
  project could drop in to satisfy the delivery gate's "CI checks quality
  gates" expectation, rather than writing that pipeline from scratch each
  time.
