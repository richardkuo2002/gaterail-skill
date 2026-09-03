# Definition of Done

The standing bar every task clears before it counts as done, regardless of
which skill produced it. Per-task acceptance criteria (from
`planning-and-task-breakdown`) and per-increment checks (from
`incremental-implementation`) sit on top of this — this is the floor under
all of them, not a replacement for either.

This is a default checklist, not a universal law. Adapt it to what a given
repository actually enforces (a repo with no type checker doesn't get one
invented for it here).

- [ ] **Requirements and acceptance criteria satisfied** — the change does
  what the spec or task said, not a superset or subset of it.
- [ ] **Tests added or updated** — new behavior has a test; changed behavior
  has an updated test; bug fixes have a regression test that failed before
  the fix (see `testing-patterns.md`).
- [ ] **Relevant checks pass** — lint, type check, build, and test, using the
  repository's own commands, not assumed defaults (`npm test` is a guess;
  the repo's `package.json` script is the fact).
- [ ] **Documentation and changelog impact considered** — if the change is
  user-visible or changes a public interface, README/CHANGELOG/docs are
  updated in the same change, not deferred.
- [ ] **No unrelated scope expansion** — no "while I'm here" refactors,
  renames, or fixes bundled into the same change. Split them out.
- [ ] **Known limitations or remaining failures explicitly reported** — if
  something couldn't be verified, or a check fails for a reason outside the
  task's scope, that's stated plainly, not implied by silence.

## Verification

- [ ] Every item above was actually checked, not assumed
- [ ] The checks were run, not just recalled from a previous pass
- [ ] Any unmet item is called out, with the reason, not silently skipped
