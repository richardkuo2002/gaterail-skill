# Request

## Initial state

`src/app.ts` has one command, `report`, which prints a fixed status summary
as human-readable text:

```
$ node dist/app.js report
GateRail status report
  ok: 2
  warn: 1
  fail: 0
Total: 3
```

There is no other output mode. Invalid arguments (missing command, unknown
command, unknown flag) already exit non-zero with a message on stderr.

## What's being asked

> Same request as the `python-cli` example, for the Node/TypeScript port:
>
> Our CI pipeline wants to parse the report's counts programmatically instead
> of scraping the text output. Can we get a `--json` mode on `report`?
>
> Constraints:
> - The existing text output must not change — other tooling already depends
>   on its exact format.
> - No new **runtime** dependency (a devDependency needed only to build or
>   type-check, like `typescript` or `@types/node`, is fine — it ships no
>   code into `dist/`).
> - Don't change what counts as an error or what exit code an error returns.
> - The build (`tsc`) and type-check (`tsc --noEmit`) must stay clean —
>   no `any`, no suppressed errors.

This is deliberately a small, single-file change — small enough that the
specification below is proportionate to it, not an example of over-process.
