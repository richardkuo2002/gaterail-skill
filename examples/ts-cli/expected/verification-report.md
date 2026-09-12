# Verification report

Status: delivery/verification gate passed locally.

This reports the result of actually running the commands from
[`approved-spec.md`](approved-spec.md)'s verification plan, from
`examples/ts-cli/`, against the code in this directory. It does not claim
GitHub Actions ran this. The actual hosted check for this example is the
root repository's `.github/workflows/ci.yml`, whose `example-tests-ts` job
runs the same build, type-check, and test commands.

## Commands run and results

```
$ npm run build

> gaterail-example-ts-cli@0.0.0 build
> tsc

(exit 0, no output — a clean tsc build produces none)
```

```
$ npm run typecheck

> gaterail-example-ts-cli@0.0.0 typecheck
> tsc --noEmit

(exit 0, no output)
```

```
$ npm test

> gaterail-example-ts-cli@0.0.0 test
> node --test dist/app.test.js

# tests 7
# suites 0
# pass 7
# fail 0
# cancelled 0
# skipped 0
# todo 0
```

```
$ node dist/app.js report
GateRail status report
  ok: 2
  warn: 1
  fail: 0
Total: 3
```

```
$ node dist/app.js report --json
{"fail":0,"ok":2,"total":3,"warn":1}
```

## Against the acceptance criteria

| # | Criterion | Result |
|---|---|---|
| 1 | Default text output unchanged | Matches the text shown in `request.md`'s initial state |
| 2 | `--json` exits 0, empty stderr, one parseable JSON line | Confirmed above and in `"--json flag produces valid JSON"` |
| 3 | JSON counts match the text report | Confirmed above (`ok: 2` / `"ok":2`, `Total: 3` / `"total":3`) and in `"json and text report the same counts"` |
| 4 | Invalid-argument behavior unchanged | Confirmed by the three invalid-argument tests (3/3 passing) |
| 5 | Build and type-check stay clean under `strict: true` | Confirmed above — both exit 0 with no output |

## Known limitations

- This report reflects one local run on the environment used to prepare
  this example (Node.js v22, TypeScript ^5.6). It is not a substitute for
  the hosted CI run on a pull request — it demonstrates what that CI job
  checks, using the same commands.
- `JSON.stringify`'s key order here is made deterministic on purpose (keys
  sorted before serializing) so this report's exact byte output is
  reproducible; that ordering is an implementation detail, not part of the
  acceptance criteria, which only constrain the parsed values.
