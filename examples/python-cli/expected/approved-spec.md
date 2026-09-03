# Approved spec: add `--json` to `report`

Status: approved before implementation (specification gate).

## Scope

- Add a `--json` flag to the `report` subcommand of `app.py`.
- When passed, print the same underlying counts as a single JSON object on
  stdout instead of the human-readable text block.
- No flag: behavior is unchanged.

## Non-goals

- No new subcommands.
- No change to what data is reported, only how it's rendered.
- No new third-party dependency (the standard library `json` module covers
  this).
- No change to argument-parsing errors, their messages, or their exit code.
- No output on stderr for the success path, in either mode.

## Acceptance criteria

1. `python app.py report` output is byte-for-byte unchanged from before this
   change.
2. `python app.py report --json` exits 0, prints nothing to stderr, and
   prints a single line to stdout that `json.loads()` can parse.
3. The JSON object's `total`, `ok`, `warn`, and `fail` values match the
   numbers shown in the text report for the same run.
4. `python app.py` (no command), `python app.py bogus` (unknown command),
   and `python app.py report --bogus` (unknown flag) all still exit non-zero
   with a message on stderr, and print nothing to stdout — unchanged from
   before this change.

## Risks

- Low. Single file, additive flag, no I/O beyond stdout, no new dependency.
- The main risk is accidentally changing the default (non-`--json`) output
  while refactoring to share logic between the two render paths — mitigated
  by acceptance criterion 1 and a test that pins the exact text output.

## Affected files

- `app.py` — add the `--json` flag and a JSON render path.
- `test_app.py` — add coverage for the new flag and for criterion 1's
  byte-for-byte guarantee; existing invalid-argument tests must keep passing
  unchanged.

## Verification plan

Run from `examples/python-cli/`:

```bash
python -m unittest -v
python app.py report
python app.py report --json
```

The delivery gate for this change is: all tests pass, and both manual
commands above produce the output described in criteria 1–4.
