---
name: linear-method
description: 'Write Linear issues the way Linear itself prescribes: short scannable titles, optional descriptions, one task with a defined outcome per issue. Use when creating, drafting, splitting, or reviewing Linear issues, projects, or epics — triggered by "file an issue", "create a ticket", "log a bug", "open an epic", "break this down into issues", "clean up this backlog", or any call to a Linear write tool. Also use when reviewing whether an existing issue is well-formed. Covers titles, descriptions, scoping, priority, sub-issues, and the templated-bloat anti-patterns that make agent-written issues unreadable.'
metadata:
  author: dillion
  version: "1.0.0"
  source: https://linear.app/method
---

# The Linear Method: writing issues

Based on the Linear Method (chapters 2.4 "Scope projects down" and 3.2 "Write issues not user stories"), adapted to how the Product Studio workspace actually writes.

## Core principle

**An issue is a task with a clear, defined outcome.** Code, a design, a document, an action. Not a container for context, not a user story, not a plan.

The default failure mode for an agent is *writing too much*. Linear's own guidance is blunt: descriptions "should be optional — not required." Most good issues are a title and one or two sentences. If you are reaching for a heading, stop and ask whether the sentence would do.

## Gate: is this even an issue?

Before writing anything, check the work passes:

| Passes | Goes elsewhere |
|---|---|
| A task someone can finish and mark Done | A half-formed idea → doc or conversation |
| Ships in hours to a day | A big feature → project, split into stages |
| Has one obvious owner | An ongoing responsibility → not an issue |
| Outcome is unambiguous from the title | A question → comment or Slack |

Exploratory work is allowed, but express it as a deliverable: "Explore X", "Write the project spec" — not "Think about X."

Sizing, per the Method: projects fit **1–3 weeks with 1–3 people**. Minor additions land "within only hours or a day." If it can't be trimmed, break it into stages rather than shipping one large unit.

## Before writing

1. **Search first.** Look for an existing issue, doc, or project covering this. Prefer updating or commenting over creating a near-duplicate.
2. **Read the neighbors.** Pull 3–5 recent issues from the same team and match their conventions — title shape, tone, length, priority usage. The team's existing style beats any template, including this one.
3. **Draft, then confirm.** Show the draft in the format under *Presenting drafts* and file only on an explicit "file it". Edits, format feedback, or "we'll do X afterwards" are not approval. Never bulk-file issues nobody asked for.

Once the user approves the draft and explicitly asks to create the issue, file that draft without another confirmation.

## Titles

Short, action-first, states the task. It will be read in a list next to fifty others, so it must survive at a glance.

- Start with the verb: `Add`, `Fix`, `Move`, `Change`, `Install`, `Join`, `Write`, `Explore`
- Name the specific object, not the category
- No prefixes, no `[tags]`, no em-dash preambles, no ticket-speak
- ~60 chars or fewer
- **Per-person task pattern:** when the same task fans out to several people, suffix the name — `Install Linear mobile app + enable push: ash`

**Completed work:** Keep the title focused on the original task and include its measurable result when useful—for example, “Reduce hosting costs from $120 to $45/month.” In the description, explain what prompted the task, what changed, and the verified outcome. Mention unresolved details without replacing the completed task with a future follow-up. Create a separate follow-up issue only when requested.

```
✅ Fix broken scroll in mobile navbar
✅ Add Superwall API key to 1Password
✅ Change Slack email to mahnoor@product.studio
❌ Navbar bug
❌ [FE] Investigate and resolve issues related to scrolling behaviour
❌ As a user, I want the navbar to scroll correctly
```

## Descriptions

Optional. Write one only when it carries information the title can't.

**Include the done-condition as a sentence, not a section.** This is the single highest-leverage habit:

> "Close this issue from your phone to confirm."
> "Comment here once Codex can drive a logged-in tab."
> "Confirm the org shows up in your Product Studio MCP."

That's acceptance criteria. It doesn't need a heading.

Rules:
- 1–3 sentences for a normal task. Headings only when an issue genuinely has multiple distinct parts.
- Second person, imperative. You're addressing the assignee.
- **Quote users verbatim.** Paste the customer's own words rather than summarizing — they describe the pain better and it's faster. Link the source conversation.
- Say *why* only when the why is non-obvious and changes how the task is done.
- Caveats and risks go in a final short paragraph, not a callout block.
- Optional work says so up front: "**Optional** — if you don't want this, mark it Cancelled. No explanation needed."

**Bugs:** version, environment, repro steps, expected vs actual, logs/screenshots. Do not speculate about root cause, name likely files, or propose a fix unless you actually verified it.

**Features:** desired end state and what it unlocks. Not a pseudo implementation plan — that's the assignee's job and writing it for them removes the thinking that makes the issue good. Use tentative verbs (could, should) over demanding ones (must, need).

## Never do these

The templated-bloat set. Each one adds length without adding information:

- `## Background` / `## Acceptance Criteria` / `## Links` scaffolding on a one-line task
- Restating the title as the first line of the description
- Repeating shared rationale across every sibling issue — it belongs in the parent or project once
- Checklists that restate the title as a single checkbox
- "This issue tracks the work to…" preambles
- Estimates, story points, or T-shirt sizes nobody asked for
- Inventing labels — labels are per-team and drift, so check the target team's recent issues before applying any. As of Oct 2026: BUS and MON use none; PLAT rarely (`Feature`/`Improvement` on product work, none on ops tasks); MKT labels every issue (`UGC`, `Ops`); HALO and COPS label most (`Planner`, `Ops`, `Bug`, `Improvement`, `Feature`).
- Pasting a URL to another issue instead of using a real Linear issue link or a Related relation

## Metadata

- **Priority** is the main signal: 1 Urgent, 2 High, 3 Medium, 4 Low (0 = No priority). Default 3 unless there's a reason.
- **Parent/sub-issues** for fan-out: one umbrella issue holding the goal, children holding the tasks. Children inherit team and project. Put the rationale in the parent *once*.
- **Relations** — use Linear's own blocks/relates-to links, not URLs in prose.
- **Assignee** — one owner. Whoever does the work ideally writes the issue themselves; when you write it for them, frame it as the ask and let them shape the solution.

## Presenting drafts

Show every draft inline in chat with one labeled field per line, in this order. The description is the exact text that will be filed, not a summary.

```markdown
**Restore Infisical access for Orbs agent and local varlock**
- 👤 **Assignee:** Dillion
- ⬜ **Status:** Todo
- 🟠 **Priority:** High
- 🏢 **Team:** Platform
- 🔗 **Related:** Cancel Infisical legacy Pro subscription
- 📝 **Description:** We deleted Orbs to stay within Free's 5-identity limit, which cut off the Orbs agent and Gurshan's local varlock. Switch both to a new Capy client secret instead of adding a 6th identity. Done when both can read Halo secrets.
```

Status and priority emoji change with the value; the rest are fixed. Colors mean priority and symbols mean status, so the two never collide.

- **Priority:** 🔴 Urgent · 🟠 High · 🟡 Medium · 🟢 Low · ⚪ No priority
- **Status**, picked by the state's *type* because names vary by team: 💤 backlog · ⬜ unstarted · ⏳ started (👀 if the state is a review) · ✅ completed · ❌ canceled · 🔁 duplicate. Write the team's own state name after it.
- **Fixed:** 👤 Assignee · 🏢 Team (full name, not the key) · 🔗 Related / Parent / Blocks (by title before filing, by ID after) · 📝 Description

Leave out fields that aren't set. End with one question ("File both?"). The colored circles are our convention: Linear itself draws High/Medium/Low as gray signal bars.

## Linear rendering gotchas

- Backtick file paths (`src/app.ts`). Linear's autolinker mangles bare paths, and **silently drops all but the first** when several bare filenames appear as bullets — it dedupes on the auto-linked name, worst with `.md`.
- Use numbered lists instead of bullets when items contain paths.
- Multi-column tables render poorly; prefer numbered lists.
- Reference issues bare (`PLAT-27`) and let Linear expand them.

## Worked example

Same task, both versions.

**Bloated (don't):**
> **Title:** [Platform] Beeper Integration Setup and MCP Connection Configuration
>
> ## Background
> In order to improve team communication workflows, we need to set up Beeper.
> ## Acceptance Criteria
> - [ ] Beeper is installed
> - [ ] Networks are connected
> - [ ] MCP is configured
> ## Links
> - https://beeper.com

**Linear Method (do):**
> **Title:** Install Beeper + connect Beeper MCP: ash
>
> **Optional** — if you don't want Beeper, mark this Cancelled. No explanation needed.
>
> Install Beeper, connect the networks you actually use, then add the Beeper MCP to Claude and ChatGPT. Try one real thing — "summarize my unread across all networks" — and comment with what worked.
>
> Don't connect the Discord bridge on an account with admin on the Halo server (ToS risk) — use the portal's `discord` MCP for server work.

Half the length, more actual information, and the done-condition is a sentence instead of a checklist.
