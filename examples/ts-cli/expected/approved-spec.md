# Approved spec: add `--json` to `report`

Status: approved before implementation (specification gate).

## Scope

- Add a `--json` flag to the `report` command of `src/app.ts`.
- When passed, print the same underlying counts as a single JSON object on
  stdout instead of the human-readable text block.
- No flag: behavior is unchanged.

## Non-goals

- No new subcommands.
- No change to what data is reported, only how it's rendered.
- No new runtime dependency — `node:util`'s `parseArgs` (stdlib) already
  covers argument parsing.
- No change to argument-parsing errors, their messages, or their exit code.
- No output on stderr for the success path, in either mode.

## Acceptance criteria

1. `node dist/app.js report` output is byte-for-byte unchanged from before
   this change.
2. `node dist/app.js report --json` exits 0, prints nothing to stderr, and
   prints a single line to stdout that `JSON.parse()` can parse.
3. The JSON object's `total`, `ok`, `warn`, and `fail` values match the
   numbers shown in the text report for the same run.
4. `node dist/app.js` (no command), `node dist/app.js bogus` (unknown
   command), and `node dist/app.js report --bogus` (unknown flag) all still
   exit non-zero with a message on stderr, and print nothing to stdout —
   unchanged from before this change.
5. `npm run build` (`tsc`) and `npm run typecheck` (`tsc --noEmit`) both
   exit 0 with no errors, under the existing `strict: true` config — no
   `any`, no `@ts-ignore`.

## Risks

- Low. Single file, additive flag, no I/O beyond stdout, no new runtime
  dependency.
- The main risk is accidentally changing the default (non-`--json`) output
  while refactoring to share logic between the two render paths — mitigated
  by acceptance criterion 1 and a test that pins the exact text output.
- A secondary risk specific to this stack: a type error that `tsc` should
  catch but doesn't because of a loosened compiler option — mitigated by
  acceptance criterion 5 checking against the repository's existing
  `tsconfig.json`, not a relaxed one written just for this change.

## Affected files

- `src/app.ts` — add the `--json` flag and a JSON render path.
- `src/app.test.ts` — add coverage for the new flag and for criterion 1's
  byte-for-byte guarantee; existing invalid-argument tests must keep passing
  unchanged.

## Verification plan

Run from `examples/ts-cli/`:

```bash
npm install
npm run build
npm run typecheck
npm test
node dist/app.js report
node dist/app.js report --json
```

The delivery gate for this change is: build and type-check both stay clean,
all tests pass, and both manual commands above produce the output described
in criteria 1–4.
