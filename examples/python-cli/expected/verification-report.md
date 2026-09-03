# Verification report

Status: delivery/verification gate passed locally.

This reports the result of actually running the commands from
[`approved-spec.md`](approved-spec.md)'s verification plan, from
`examples/python-cli/`, against the code in this directory. It does not
claim GitHub Actions ran this. The `.github/workflows/ci.yml` file in this
directory documents how the example would run in CI if it were extracted
into its own repository — GitHub Actions does not discover workflow files
nested under a subdirectory of this repository, so it never executes here.
The actual hosted check for this example is the root repository's
`.github/workflows/ci.yml`, whose `example-tests` job runs the same test
command.

## Commands run and results

```
$ python -m unittest -v
test_missing_command_exits_nonzero_with_stderr ... ok
test_unknown_command_exits_nonzero_with_stderr ... ok
test_unknown_flag_on_report_exits_nonzero_with_stderr ... ok
test_json_and_text_report_the_same_counts ... ok
test_json_flag_produces_valid_json ... ok
test_default_output_is_human_readable_text ... ok
test_text_output_is_not_valid_json ... ok

----------------------------------------------------------------------
Ran 7 tests in 0.343s

OK
```

```
$ python app.py report
GateRail status report
  ok: 2
  warn: 1
  fail: 0
Total: 3
```

```
$ python app.py report --json
{"fail": 0, "ok": 2, "total": 3, "warn": 1}
```

## Against the acceptance criteria

| # | Criterion | Result |
|---|---|---|
| 1 | Default text output unchanged | Matches the text shown in `request.md`'s initial state |
| 2 | `--json` exits 0, empty stderr, one parseable JSON line | Confirmed above and in `test_json_flag_produces_valid_json` |
| 3 | JSON counts match the text report | Confirmed above (`ok: 2` / `"ok": 2`, `Total: 3` / `"total": 3`) and in `test_json_and_text_report_the_same_counts` |
| 4 | Invalid-argument behavior unchanged | Confirmed by `TestInvalidArguments` (3/3 passing) |

## Known limitations

- This report reflects one local run on the environment used to prepare this
  example. It is not a substitute for the hosted CI run on a pull request —
  it demonstrates what that CI job checks, using the same command.
