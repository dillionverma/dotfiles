# Command output

Command output here is condensed by RTK to save tokens, keeping every signal
and dropping costly noise. A hook rewrites shell commands automatically, so run
them normally. Treat the output as the complete result. Batch related commands
into one call to avoid extra turns. Truncated results state
their recovery path in their own output. Re-run a command as `rtk proxy <cmd>`
only when its result is unusable: empty when output was clearly expected,
contradicting its exit code, or garbled.

# Projects

Read relevant [new-project.md](/Users/dillion/.agents/new-project.md) sections
before web project, code, dependency, or UI/UX changes. Preserve existing
conventions unless a change is requested or justified.

# Documentation

Keep summaries and explanations in chat. Create documentation only when asked;
update existing docs when needed.

# Personal archive

For questions about Dillion's archived records or media, or finding NAS files,
use the [digup skill](/Users/dillion/.agents/skills/digup/SKILL.md).

# Linear

Before drafting or filing any Linear issue, invoke the `linear-method` skill and
match the target team's recent issues.

# Package installs

When installing a new machine-wide package or app, ask whether to also add it
to `/Users/dillion/src/personal/dotfiles`. Skip the question if the user already
specified whether to add it, or the package is already declared there. Do not
block an authorized install while waiting for the dotfiles preference. If the
user says yes, update the repo's existing package configuration and verify it.
Keep project-local dependencies in their project manifests and lockfiles.

# Agent instructions and skills

`~/.agents/` is the single source for agent instructions, skills and hooks.
Every tool's copy is a symlink to it: `~/.claude/CLAUDE.md` and
`~/.codex/AGENTS.md` link to `~/.agents/AGENTS.md`, `~/.claude/skills/<name>`
links to `~/.agents/skills/<name>`, `~/.claude/settings.json` links to
`~/.agents/claude/settings.json`, and `~/.codex/hooks.json` links to
`~/.agents/codex/hooks.json`. Shared hook scripts live in `~/.agents/hooks/`;
keep Claude and Codex hooks in step. Never add instructions, skills or hooks
directly under `~/.claude` or `~/.codex`. `~/.agents/` itself is versioned in
the dotfiles repo under `config/agents/`.

# Git worktrees

Never create worktrees as siblings of a repo (for example `../<repo>-<topic>`).
Use the tool's own worktree location, or ask where to put one.

# Keep ongoing work moving

When the user answers a question or completes a step in an ongoing task, apply
their answer and advance the task. Do the next authorized action yourself when
possible. If you need user input, end with the next specific question or a small
batch of related questions, including enough context to answer in chat. Do not
end with only an acknowledgment, status update, or remaining-item count, or make
the user ask "what's next?" or approve routine continuation. Stop when the task
is complete or the user asks to pause; do not invent extra work.

# Pstack

For multi-file coding changes, architecture decisions, unknown-cause bugs, or
performance work, invoke `pstack:poteto-mode`. For a focused design or review,
use `pstack:architect` or `pstack:interrogate` directly. Handle small, obvious
edits directly. Apply explicit task scope, permissions, and repository
conventions throughout.

# MCP routing

- **Personal:** `personal` at `https://mcp.dillion.io/mcp`. Personal Google,
  GitHub, Notion, Todoist, and **Dillions Personal** Cloudflare;
  `vermadillion@gmail.com` / `hello@dillion.io`.
- **Work:** the Product Studio portal (`productstudio-mcp` in Claude Code,
  `product-studio` in Codex) at `https://mcp.product.studio/mcp`. Product
  Studio/Halo accounts and resources; `dillion@product.studio`. Use the `portal`
  skill.

Route by resource ownership, not login or checkout. For a work resource, prefer
the portal over any other MCP server or plugin bridge for the same service, and
fall back only when it lacks the capability. Inspect account/workspace metadata;
ask if still ambiguous. Verify live tools and the target account before writes.
Never substitute portals or transfer data between personal and work accounts
without instruction.

# MCP authentication

For missing tools or failed auth, check the existing connection, start supported
reauthentication, and open its sign-in URL automatically. Never duplicate server
configs. Leave sign-in and consent to the user, then retry the requested read.
Report failures or required reloads precisely; saved credentials do not prove
connectivity. Do not loop on the same error.

# Browser

Prefer available MCP/API tools. When browser interaction is needed,
use the `aside-browser` skill and run `aside guide` before using Aside.
Use `aside exec` for delegated browser tasks. For direct DOM or screenshot
inspection, read `aside guide repl` before using `aside repl`.

When the user authorizes signing in with saved credentials, try the available
vault and supported autofill methods before asking them to sign in. Keep
passwords and verification codes out of outputs. Verify the resulting account
and signed-in state; if blocked, report the exact failure and attempts made.
