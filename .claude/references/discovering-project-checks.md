# Discovering a Project's Own Checks

Every delivery-gate skill says the same thing: verify with the repository's
own commands, not assumed defaults. This reference is the concrete procedure
for finding those commands, and what to do when they don't exist.

## Where to look, in order

Stop at the first source that gives you a working command; later sources
confirm or fill gaps.

1. **CI workflows** — `.github/workflows/*.yml`, `.gitlab-ci.yml`,
   `Jenkinsfile`, `.circleci/config.yml`. These are the commands that
   actually gate merges, so they outrank everything below. Copy the exact
   invocation, including flags and working directory.
2. **Checked-in wrappers and task runners** — `Makefile`, `justfile`,
   `Taskfile.yml`, `./gradlew`, `./mvnw`, a scripts directory. A wrapper
   the repo ships always beats a globally installed tool.
3. **Manifest scripts** — `package.json` `"scripts"`, `pyproject.toml`
   (`[tool.*]` sections and any task runner config), `Cargo.toml`,
   `composer.json` `"scripts"`. Read the script body, not just its name:
   `"test": "echo 'no tests yet'"` is not a test command.
4. **Documentation** — README, CONTRIBUTING, docs on development setup.
   Trust these less than CI: docs drift, CI doesn't.
5. **Tool config files as hints** — `.eslintrc*`, `ruff.toml`, `.golangci.yml`,
   `tsconfig.json`, `pytest.ini`. A config file proves the tool is intended,
   even when no script wires it up; run the tool the way its config implies.

## Verify before you rely on it

Run the discovered command once, on the unmodified tree, before using it as
a gate. If it fails on a clean checkout, it can't tell you anything about
your change — report the pre-existing failure instead of silently picking a
different command.

## When no checks exist

A repository with no test command, no lint, and no CI still gets a delivery
gate — it's just thinner, and you must say so:

- **Don't fabricate a pass.** Never claim "checks pass" when there were no
  checks to run. State explicitly which gates were unavailable.
- **Run what does exist.** A build or compile step (`tsc --noEmit`,
  `go build ./...`, `python -m compileall`) is still a real check. Syntax-level
  checks (`bash -n`, `python -m py_compile`) beat nothing.
- **Leave one check behind.** If you implemented non-trivial logic, add the
  smallest self-contained test the stack supports and wire it to the most
  obvious entry point (a `test` script, a `make test` target). Propose CI
  in a follow-up rather than bundling it into an unrelated change.
- **Say what "done" means in the report.** Without repository checks, "done"
  means "the acceptance criteria in the spec were each verified manually" —
  list how each one was checked.

## Common mistakes

- Running `npm test` in a repo whose CI runs `npm run test:unit -- --ci` —
  discover the exact command, not the family.
- Using a globally installed tool version when the repo pins one
  (lockfile, `.tool-versions`, `rust-toolchain.toml`, wrapper script).
- Treating a linter's auto-fix mode as the check (`eslint --fix` mutates the
  tree; the gate is the non-fixing invocation CI runs).
- Discovering commands once and caching them forever — re-check when you
  touch a different package in a monorepo; per-package commands differ.
