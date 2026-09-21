# Roadmap

No dates. Items move here when there's a concrete next step, and out when
they're done or dropped.

## Near-term (committed direction)

- (nothing currently committed — recently shipped: compatibility coverage
  in `docs/compatibility.md`, and the repository-defined checks guide in
  `.claude/references/discovering-project-checks.md`)

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
