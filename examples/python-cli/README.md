# Example: python-cli

A minimal, self-contained example of the GateRail workflow — the
specification gate and the delivery/verification gate — applied to one small,
real change. It uses only the Python standard library and doesn't call an
LLM: the point is to show the artifacts the workflow produces, not to
simulate an agent session.

## The story

1. **Initial state** — `app.py` has a `report` command that prints a
   human-readable report and nothing else.
2. **Request** — [`expected/request.md`](expected/request.md): add a
   `--json` output mode without changing the default output, adding
   dependencies, or changing error/exit-code behavior.
3. **Specification gate** — [`expected/approved-spec.md`](expected/approved-spec.md):
   scope, non-goals, acceptance criteria, risks, affected files, and the
   exact verification commands, before any code changed.
4. **Implementation** — `app.py` and `test_app.py` in this directory are the
   result: `--json` added, default output unchanged.
5. **Delivery/verification gate** — [`expected/verification-report.md`](expected/verification-report.md):
   the actual result of running the commands below.

## Run it yourself

```bash
python -m unittest -v
python app.py report
python app.py report --json
```

Standard library only — no `requirements-dev.txt`, `pip install`, or virtual
environment needed. `unittest` (stdlib) is enough here; if a project's test
suite needs fixtures, parametrization, or plugins beyond that, that's when a
`requirements-dev.txt` with `pytest` (or similar) earns its place — this
example's scope doesn't reach that.

`test_app.py` runs `app.py` as a subprocess via `sys.executable` and checks
stdout, stderr, and exit status — including for invalid arguments — rather
than importing its functions, so the tests exercise exactly what a user
would type.
