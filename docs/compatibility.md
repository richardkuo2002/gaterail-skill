# Compatibility Coverage

What each skill's examples assume, versus where its guidance is
stack-agnostic. "Exercised concretely" means this repository contains a
worked example or CI job actually running that shape; "illustrative" means
the code blocks show one stack but the instructions are written to transfer.

| Skill | Stack shown in examples | CI provider shown | Guidance itself |
|---|---|---|---|
| `spec-driven-development` | One `npm`-based command block | none | Stack-agnostic; the spec/plan/tasks flow has no tooling dependency |
| `planning-and-task-breakdown` | none | none | Fully stack-agnostic |
| `api-and-interface-design` | TypeScript, REST/GraphQL | none | Principles transfer; naming/versioning tables are HTTP-centric |
| `incremental-implementation` | TypeScript snippets | none | Stack-agnostic; verification defers to the repository's own commands |
| `test-driven-development` | TypeScript/Jest | none | Cycle is universal; "Discover the Stack First" section handles other stacks |
| `ci-cd-and-automation` | Node.js pipeline (eslint, tsc, jest, npm audit) | **GitHub Actions only** | Gate concepts transfer, but every config example is GitHub Actions YAML |
| `git-workflow-and-versioning` | JS/TS pre-commit commands | none | Git guidance is universal; command checklist notes the substitution |

Shared references:

| Reference | Assumptions |
|---|---|
| `definition-of-done.md` | None — stack-agnostic checklist |
| `testing-patterns.md` | **JS/TS-specific by design** (Jest, React Testing Library, Supertest, Playwright); stated in the file itself |
| `discovering-project-checks.md` | None — covers JS, Python, Go, Rust, JVM, Ruby, PHP discovery sources |

## Exercised concretely in this repository

- [`../examples/python-cli/`](../examples/python-cli/) — stdlib Python +
  `unittest`, run in CI (`example-tests` job).
- [`../examples/ts-cli/`](../examples/ts-cli/) — TypeScript/Node with real
  `tsc` build and type-check gates, run in CI (`example-tests-ts` job).
- This repository's own CI (`.github/workflows/ci.yml`) — GitHub Actions,
  Bash, Python.

## Known gaps

- No worked example for a JVM, Go, Rust, or Ruby project — the delivery
  gate there relies on the discovery procedure, not a checked-in
  demonstration.
- No CI provider other than GitHub Actions is shown anywhere.
  `ci-cd-and-automation`'s concepts apply to GitLab CI, Jenkins, etc., but
  you translate the YAML yourself.
