# Security Policy

## Supported versions

This project has not yet made a tagged release. Until then, only the latest
commit on `main` is supported — there is no older version to backport a fix
to.

## Reporting a vulnerability

Please **do not** open a public GitHub issue for a security vulnerability
(for example: a way to make `install.sh` write, replace, or delete files
outside the destination you chose, or outside what this doc describes).

Instead, use GitHub's private vulnerability reporting for this repository:
open the repository's **Security** tab → **Report a vulnerability**. This
opens a private draft advisory visible only to the maintainer, without
disclosing details publicly.

If that feature isn't enabled on this repository at the time you're
reading this, open an issue asking the maintainer to enable it, without
including any exploit details in that issue.

## Scope

`install.sh` and the skill/reference files it copies are the main
security-relevant surface here: they're the only part of this project that
touches your filesystem. The `SKILL.md` files themselves are instructions
read by Claude Code, not executable code — a concern with what a skill
*instructs* an agent to do belongs in a regular issue, not a security
report, unless it describes a concrete way to make the installer act outside
its documented destinations.
