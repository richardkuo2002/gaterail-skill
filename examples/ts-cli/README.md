# Example: ts-cli

A second, minimal GateRail worked example — same request, same two gates, as
[`../python-cli/`](../python-cli/), but in TypeScript/Node instead of
stdlib Python. The point of having both: it shows the specification and
delivery/verification gates transfer across ecosystems, and this one adds a
**build step and a real type-checker** to the delivery gate — checks the
Python example's stack doesn't have — per [ROADMAP.md](../../ROADMAP.md)'s
"different ecosystem" item.

## The story

Same shape as `python-cli`'s:

1. **Initial state** — `src/app.ts` has a `report` command that prints a
   human-readable report and nothing else.
2. **Request** — [`expected/request.md`](expected/request.md): add a
   `--json` output mode without changing the default output or adding a
   runtime dependency.
3. **Specification gate** — [`expected/approved-spec.md`](expected/approved-spec.md):
   scope, non-goals, acceptance criteria, risks, affected files, and the
   exact verification commands — including the build and type-check steps
   this stack has that the Python example doesn't.
4. **Implementation** — `src/app.ts` and `src/app.test.ts` in this directory
   are the result: `--json` added, default output unchanged.
5. **Delivery/verification gate** — [`expected/verification-report.md`](expected/verification-report.md):
   the actual result of running the commands below.

## Run it yourself

```bash
npm install   # installs typescript + @types/node — the only devDependencies,
              # no runtime dependency either example ships with
npm run build      # tsc: compiles src/ to dist/ — this IS the build step
npm run typecheck  # tsc --noEmit: same type-check, no output files
npm test           # node --test dist/app.test.js
node dist/app.js report
node dist/app.js report --json
```

`node:util`'s `parseArgs` plays the role `argparse` plays in the Python
example — stdlib argument parsing, no CLI-parsing package. `node:test` +
`node:assert` play the role `unittest` plays — no test-framework dependency
either.

`src/app.test.ts` runs the **compiled** `dist/app.js` as a subprocess (via
`node:child_process`'s `spawnSync`), the same way `python-cli`'s
`test_app.py` runs `app.py` — checking stdout, stderr, and exit status
rather than importing internals, so both examples test exactly what a user
would type.
