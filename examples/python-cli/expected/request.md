# Request

## Initial state

`app.py` has one command, `report`, which prints a fixed status summary as
human-readable text:

```
$ python app.py report
GateRail status report
  ok: 2
  warn: 1
  fail: 0
Total: 3
```

There is no other output mode. Invalid arguments (missing command, unknown
command, unknown flag) already exit non-zero with a message on stderr, via
`argparse`'s defaults.

## What's being asked

> Our CI pipeline wants to parse the report's counts programmatically instead
> of scraping the text output. Can we get a `--json` mode on `report`?
>
> Constraints:
> - The existing text output must not change — other tooling already depends
>   on its exact format.
> - No new dependencies — this is a small internal script, keep it
>   stdlib-only.
> - Don't change what counts as an error or what exit code an error returns.

This is deliberately a small, single-file change — small enough that the
specification below is proportionate to it, not an example of over-process.
