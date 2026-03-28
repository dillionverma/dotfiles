---
name: conventional-commit-lint
description: Add, enforce, and validate Conventional Commits in a Git repository using CLI tools. Use when Codex needs to install or configure commitlint, add a commit-msg hook, lint commit messages, rewrite invalid commit messages into Conventional Commit form, or enforce commit-message standards in a repo.
---

# Conventional Commit Lint

## Overview

Use `commitlint` to validate commit messages and enforce Conventional Commits through a Git `commit-msg` hook. Prefer repo-local configuration over global installation so the rule set stays versioned with the repo.

## Quick Start

- Lint one message with `scripts/lint_commit_message.sh "feat(api): add retry logic"`.
- Lint a pending commit message file with `scripts/lint_commit_message.sh --edit .git/COMMIT_EDITMSG`.
- Install repo enforcement with `scripts/setup_commitlint.sh /path/to/repo`.

## Workflow

### Lint a message

- Run `scripts/lint_commit_message.sh` for one-off validation.
- Prefer the repo-local `./node_modules/.bin/commitlint` when available.
- Fall back to a global `commitlint` binary only when the repo does not manage its own dependency.

### Enforce in a repo

- Run `scripts/setup_commitlint.sh <repo-path>`.
- Prefer local dev dependencies:
  - `@commitlint/cli`
  - `@commitlint/config-conventional`
- Write `commitlint.config.cjs` extending `@commitlint/config-conventional`.
- Install a Git `commit-msg` hook that runs local `commitlint --edit "$1"`.
- If the repo already has a `commit-msg` hook or a hook manager such as Husky, inspect the existing behavior first and integrate there instead of overwriting blindly.

### Rewrite invalid messages

- Convert freeform messages into valid Conventional Commit form before committing or amending.
- Prefer the smallest accurate type and scope.
- Common forms:
  - `feat(scope): add capability`
  - `fix(scope): correct behavior`
  - `refactor(scope): restructure code without behavior change`
  - `docs(scope): update documentation`
  - `chore(scope): maintenance work`

## Guardrails

- Do not default to global commitlint installation for repo enforcement.
- Do not overwrite an existing `commit-msg` hook without reading it first.
- Do not invent custom commitlint rules unless the repo already uses them or the user requests them.
- If a repo has no `package.json`, either initialize one first or get explicit approval to use a global-only enforcement path.

## Resources

### scripts/

- `scripts/lint_commit_message.sh`: lint a message string or a `COMMIT_EDITMSG` file using local or global `commitlint`.
- `scripts/setup_commitlint.sh`: install `commitlint` in a target repo, create `commitlint.config.cjs`, and add a `commit-msg` hook.
