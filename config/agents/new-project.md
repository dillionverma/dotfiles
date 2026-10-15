# Web-project preferences

## How to use this file

These are defaults for new web applications and relevant changes to existing
applications. Explicit task requirements take precedence. Preserve established
project conventions unless a change is requested or justified.

Read the decision rules and the sections relevant to the task. Examples are
minimal starting points, not a required folder layout or a list of features to
install. Discover actual workspace members, source roots, runtime boundaries,
and generated outputs before adding project-specific configuration. Keep resolved
versions and compatibility exceptions in the project.

| Task | Read |
| --- | --- |
| Start a project or change dependencies | [Setup and version policy](#setup-and-version-policy), [Repository structure](#repository-structure), [Tooling and example configurations](#tooling-and-example-configurations) |
| Change folders, imports, or package ownership | [Repository structure](#repository-structure) |
| Configure checks, hooks, or task caching | [Tooling and example configurations](#tooling-and-example-configurations) |
| Build UI, forms, lists, or charts | [Frontend and UI](#frontend-and-ui) |
| Change APIs, authentication, or storage | [Backend and data](#backend-and-data) |
| Configure Cloudflare or delivery | [Infrastructure and deployment](#infrastructure-and-deployment) |
| Add jobs, AI, email, logs, or analytics | [Optional services](#optional-services) |
| Verify release readiness | [Performance and agent readiness](#performance-and-agent-readiness) |

### Decision rules

- Keep implementations direct. Add dependencies, abstractions, and services
  when they solve an existing problem.
- Prefer Cloudflare where suitable; verify availability and plan requirements.
  Report relevant constraints in the conversation.
- Choose deployment stages, API access, authentication providers, collection
  schedules, capacity thresholds, and testing strategy per project.
- Update this global file only when explicitly requested or approved. Keep
  project configuration in the project and update existing documentation there.
- Keep this as the detailed source of truth and AGENTS.md as its concise index.
  Keep task summaries and walkthroughs in the conversation.

## Setup and version policy

1. Inspect the existing project and relevant preferences before generating code.
2. Select compatible releases, then inspect Better T Stack's supported options.
   For migrations, generate in a scratch directory and transfer useful pieces.
   Preserve existing data and configuration.
3. Establish the workspace and runtime boundaries, then configure shared checks.
   The development command must start the actual application and its bindings.
4. Prove one representative end-to-end operation before expanding the scaffold.
5. Verify relevant behavior and run the release checks for the finished change.

- Prefer the latest compatible releases, including new major versions. Beta
  and release-candidate releases are acceptable.
- Check current releases, peer dependencies, and official docs during setup
  or dependency upgrades; do not rely on remembered versions or scaffold defaults.
- Keep resolved versions in each project's package metadata and lockfile, not
  in this global file. Record any compatibility constraint requiring an older release.
- Install commands below are starting points. Use docs matching the selected
  releases; follow migration guidance when upgrading existing projects.

- Prefer Better T Stack when it supports the selected stack. Inspect its output,
  remove unused features, and add missing integrations. Scaffold manually only
  when the CLI cannot reasonably support the requirements.
- Keep useful official or maintainer-provided repository skills; inspect their
  instructions and remove redundant or irrelevant additions.
- When project AGENTS.md changes are requested, keep the index concise and link
  to existing project documentation.

## Repository structure

- Prefer apps/, packages/, and scripts/ for monorepo source, alongside normal
  root configuration files and .github. Use a single application layout when
  workspaces would add no value.
- Split applications along actual deployment boundaries. Prefer one full-stack
  deployment when frontend and backend share a lifecycle; create a separate
  server application only when it deploys independently.
- Colocate related product code. Let the selected framework determine required
  route and entry files; choose other folders from the actual domain. Names such
  as routes, features, or components are not universal configuration assumptions.
- Keep UI components in their application until another application needs them.
  Introduce shared packages only for real responsibilities and consumers.
- In a monorepo using Alchemy, keep infrastructure in packages/infra. Add
  contracts, authentication, database, and shared configuration packages only
  when their responsibilities justify separate packages.
- Serve optional API reference docs from the application where practical.
  Documentation does not require another package or deployment.

### Reference layout

This illustrates ownership, not exact folder names. Angle-bracketed names are
placeholders; omit directories that the project does not need.

```text
apps/
  <application>/
    src/                      # Framework entries and colocated product code
    public/                   # Only if the framework uses this convention
    package.json
    tsconfig.json
    vite.config.ts            # Application plugins and build/runtime setup
packages/
  <shared-package>/
    src/
    package.json
  infra/                      # When using Alchemy
    alchemy.run.ts
scripts/                      # Operational tooling, only when needed
.github/workflows/            # When using GitHub Actions
package.json                  # Bun workspaces and root commands
bun.lock
vite.config.ts                # Shared checks, formatting, and tasks
README.md
AGENTS.md
```

### Workspace and package boundaries

- Use one root Bun workspace and lockfile. Declare actual JavaScript/TypeScript
  members in the root manifest and use `workspace:*` for internal dependencies.
  Mark non-published packages private.
- Each package declares the dependencies it imports. Keep shared development
  tooling at the root and runtime dependencies with consumers; do not rely on
  accidental root hoisting.
- Give packages explicit exports and clear responsibilities. Keep browser-safe
  contracts separate from backend implementations, authentication secrets,
  database clients, and infrastructure. Avoid cycles and catch-all packages.
- Keep infrastructure out of application runtime imports. Use the framework's
  server-only boundaries rather than inferring safety from a folder name.
- Keep framework entry points thin without imposing a controller/service/
  repository chain on every feature.
- For SSR, use a request-local query client and call shared server operations in
  process where possible rather than fetching the application's own endpoints.
- Prefer source exports for internal TypeScript packages consumed by the
  application bundler. Build independent artifacts only when distribution or a
  runtime requires them.
- Derive generated interfaces from one authored source. Make generation
  deterministic and check drift when outputs are committed.
- Keep development, verification, and deployment commands discoverable.

### Import aliases

- Use configured aliases for internal source imports and re-exports, including
  types. Choose aliases from the real source roots rather than a fixed directory
  template; relative imports are not the default.
- Configure TypeScript paths and the bundler/runtime consistently. TypeScript
  paths alone do not rewrite runtime imports. Align shadcn aliases and any test
  runner with the same source roots.
- Configure linting and editor auto-imports to prefer the chosen aliases.
- Import other workspace packages through public exports, not source aliases
  that bypass their declared interfaces.

### Workspace manifest example

Root package.json fragment for projects using this monorepo layout. Adjust
workspace patterns to the actual package locations, omit unused commands, and
add the selected dependencies and pinned `packageManager` during setup.

```json
{
  "private": true,
  "type": "module",
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "check": "vp check",
    "fix": "vp check --fix",
    "build": "vp run -r build"
  }
}
```

An internal source package exposes its intentional entry points through
`exports`; consumers declare its actual package name with `workspace:*`.
Do not create a sample package just to match this example.

## Tooling and example configurations

Use strict TypeScript, Bun for packages/scripts, and Vite+ for development,
builds, checks, formatting, hooks, and workspace tasks. Prefer this task runner
before adding another orchestrator.

| Tool | Owns |
| --- | --- |
| Vite+ with Ultracite presets | Type-aware linting, type checking, formatting, staged checks |
| Fallow | Dead-code and dependency analysis; advisory structural analysis |
| React Doctor | React-specific diagnostics |
| Alchemy | Local Cloudflare runtime and infrastructure/deployment operations |

Keep shared tooling at the root. Use installed project binaries; pin selected
versions in the lockfile. Avoid overlapping lint/format stacks and hook managers.

### Root Vite+ and Ultracite configuration

Root `vite.config.ts` owns `lint`, `fmt`, `staged`, and shared tasks. Use root
overrides for file-specific behavior; workspace-root checks do not merge nested
lint/format blocks. Application Vite configs own framework plugins, bundling,
and runtime integration. [Vite+ monorepo guide](https://viteplus.dev/guide/monorepo)

This baseline contains no application paths or framework-generated filenames.
It preserves Ultracite's own defaults and disables its implicit browser globals.
Add runtime-specific globals only after identifying where that code executes.

```ts
import { defineConfig } from "vite-plus";
import core from "ultracite/oxlint/core";
import format from "ultracite/oxfmt";

export default defineConfig({
  lint: {
    extends: [core],
    options: { typeAware: true, typeCheck: true },
    env: { browser: false, node: false },
    ignorePatterns: core.ignorePatterns,
  },
  fmt: format,
  staged: {
    "*.{js,jsx,ts,tsx,mjs,cjs,mts,cts}": "vp check --fix",
    "*.{json,jsonc,css,md,yml,yaml}": "vp fmt",
  },
  run: {
    cache: { scripts: false, tasks: false },
  },
});
```

### Adapt the baseline to the project

- Inspect manifests, framework configuration, and actual entry points first.
  Do not guess source paths from names such as routes or features.
- Add `ultracite/oxlint/react` for React code and
  `ultracite/oxlint/tanstack` for TanStack code when those frameworks are used.
  Scope overrides to real workspace/source boundaries and preserve each preset's
  rules, plugins, and framework exceptions when composing them.
- Enable browser, Worker, or Node globals only for code running in that
  environment. Use package boundaries or explicit framework server/client
  conventions where possible; browser globals do not make code safe during SSR.
- Keep preset ignore patterns. Add exclusions only for generated or vendored
  output that actually exists and needs them. Do not preemptively ignore guessed
  route trees, output directories, or whole source packages.
- If Tailwind needs stylesheet or utility-function configuration, derive it
  from the actual installed version and application configuration. Preserve
  formatter preset settings and align editor formatting with Oxfmt.
- Verify type checking covers every authored TypeScript workspace; add another
  checker only for a demonstrated framework or language gap.
  [Vite+ check](https://viteplus.dev/guide/check)
- Keep Vite, Vite+, framework plugins, and required package overrides compatible.
  Derive any Vite override from the selected release's setup guidance.
- Use Ultracite as configuration through Vite+; avoid an initializer that creates
  a competing lint/format setup. [Ultracite presets](https://www.ultracite.ai/docs/faq)

### Task execution and caching

- The example disables caching until a task is deliberately configured.
  Cache deterministic builds/checks only, with correct file and environment
  inputs. Use workspace dependencies for execution ordering.
- Keep dev servers, infrastructure plans, deployments, migrations, backfills,
  publishing, live audits, and generation that edits tracked files uncached.
  These operations must execute rather than replay a successful old result.
- Simple commands belong in package scripts. Use a task definition for explicit
  dependencies or caching; do not define the same task name in both places.
- For Workers, root `dev` must start Alchemy's integrated local runtime with its
  bindings. Invoke the project script with `bun run dev` or `vp run dev`.
  Bare `vp dev` runs Vite's built-in server rather than that script.
- Give CI explicit targets derived from actual workspace members, or use the
  workspace build scripts. Avoid commands that need an interactive app picker.

Use the selected release's [task runner](https://viteplus.dev/guide/run) and
[cache configuration](https://viteplus.dev/config/run) for per-task opt-in and
dependency declarations. Keep credentials out of logs and cached output.

### Hooks and CI

Project-owned `scripts/hooks/pre-commit`:

```sh
#!/bin/sh
vp staged
```

Set up and inspect the dispatcher with the selected release's equivalent of:

```sh
vp config --hooks-dir scripts/hooks --no-agent
vp hooks status
```

Commit authored hook scripts and ignore generated dispatchers. Preserve existing
agent instructions. Check the selected Vite+ release's Node and Git requirements
even when Bun manages dependencies. The root `staged` example runs safe source
fixes and formats other supported files. Do not add another staged-file config
or hook manager. [Vite+ commit hooks](https://viteplus.dev/guide/commit-hooks)

CI installs with a frozen lockfile, then runs full static checks, applicable
Fallow/React Doctor checks, and builds through the same commands. Staged checks
do not replace full verification; expensive or network checks belong in CI.

### Fallow configuration

Root `.fallowrc.jsonc` starting point:

```json
{
  "$schema": "./node_modules/fallow/schema.json",
  "includeEntryExports": false,
  "rules": {
    "unused-files": "error",
    "unused-dependencies": "error",
    "unresolved-imports": "error",
    "unlisted-dependencies": "error",
    "unused-exports": "warn",
    "unused-types": "warn"
  }
}
```

First inspect detected entry points and plugins:

```sh
fallow doctor
fallow recommend --format json
fallow list --entry-points --plugins --workspaces
```

Keep automatic framework and package detection as the starting point. Add
`entry` only for real roots it missed, using paths discovered in the project.
Add `ignorePatterns` only for actual generated output that needs exclusion.
Do not mark entire source folders as roots. Public package exports remain
intentional interfaces.

Use `fallow dead-code` for reviewed blocking checks. The example leaves unused
exports/types as warnings during adoption; review them before tightening.
Investigate uncertain findings with tracing or type-aware analysis before
deleting code. Keep duplication/complexity advisory with `fallow dupes`,
`fallow health --report-only`, and `fallow review --brief`.
Check CLI failure semantics before using blanket CI flags that promote warnings.
[Fallow configuration](https://fallow.tools/docs/configuration/overview/)

### React Doctor configuration

Place `doctor.config.ts` in the React application being scanned:

```ts
import { defineConfig } from "react-doctor/api";

export default defineConfig({
  scope: "full",
  blocking: "error",
  noScore: true,
  share: false,
  adoptExistingLintConfig: false,
  supplyChain: { enabled: false },
});
```

Run `react-doctor . --no-telemetry` from that application's directory. For root
scripts, choose the actual React workspace explicitly. Add file exclusions only
when observed generated output requires them.
The example disables hosted scoring/sharing and optional network supply-chain
checks; it does not replace the project's dependency-security workflow.

Resolve blocking findings and review warnings. Leave optional graph/dependency
rules to Fallow. Use narrow, explained exceptions for architecture conflicts;
disable overlapping duplicate-JSX advice only if Fallow's review owns that check.
Do not enable React Compiler or rewrite working architecture to improve a score.
[React Doctor configuration](https://www.react.doctor/docs/configuration/config-files)

### Command conventions

Expose commands at the root for the features the project actually has. Use
package-local implementations behind these commands; omit irrelevant commands.

| Command | Responsibility |
| --- | --- |
| `dev` | Start the integrated application and local infrastructure runtime |
| `check` / `fix` | Shared static verification / safe lint and formatting fixes |
| `check:dead-code` | Reviewed blocking Fallow checks |
| `doctor` | React Doctor checks for React applications |
| `audit:structure` | Advisory duplication and complexity review |
| `build` | Build deployable applications and required package artifacts |
| `db:generate` / `auth:generate` | Produce schema changes for migration review |
| `api:generate` | Generate an OpenAPI artifact when the API/docs workflow needs one |
| `plan` / `deploy` | Preview or apply Alchemy infrastructure changes |

## Frontend and UI

- Prefer TanStack Start for full-stack React applications, with TanStack Router
  and file-based routing. Use SSR for public content and agent discoverability;
  choose rendering behavior per route according to product needs.
- Use TanStack Router without Start for genuinely client-only applications.
- TanStack Query for server state, using [oRPC's TanStack Query integration](https://orpc.dev/docs/integrations/tanstack-query)
  and the matching `@orpc/tanstack-query` release.
- Prefer TanStack Query infinite queries with TanStack Virtual over pagination
  for long lists. Follow the [infinite-scroll integration example](https://tanstack.com/virtual/latest/docs/framework/react/examples/infinite-scroll).
- Tailwind CSS and shadcn/ui with Base UI primitives.
- Prefer accessible shadcn components; preserve their default
  styling and minimize custom overrides.
- Prefer dnd kit for drag-and-drop interactions.
- Prefer Motion for animations; use CSS transitions for simple hover and fade effects.
- Prefer shadcn/ui's Command component for command palettes and keyboard-driven
  switchers, with Cmd+K on macOS and Ctrl+K elsewhere.
- Use [nuqs](https://nuqs.dev/) for URL-backed UI state. This is mandatory
  for shareable view state: search, filters, sorting, pagination, selected
  tabs, and date ranges.
- Use the URL as the source of truth for this state, with typed parsers and
  explicit defaults. Support refresh, copied links, and browser back/forward.
- Integrate through the adapter for the project's framework/router.
  For TanStack Router, follow the [official integration](https://nuqs.dev/docs/adapters#tanstack-router)
  and connect shared parsers to route search validation. Check adapter support
  for the selected framework and version during setup.
- Keep transient interactions and unsaved form input in local React state;
  keep server data in TanStack Query.
- Install with `bun add nuqs`.
- Use the component defaults below. Prefer Base UI variants where available;
  use existing APIs, keyboard shortcuts, and integrations before adding custom
  behavior.

| Use case | Default and docs | Install or setup |
| --- | --- | --- |
| Content lists | Prefer [shadcn Item](https://ui.shadcn.com/docs/components/base/item) | `bunx --bun shadcn@latest add item` |
| Loading placeholders | Prefer [Skeleton](https://ui.shadcn.com/docs/components/base/skeleton) over spinners | `bunx --bun shadcn@latest add skeleton` |
| Notifications | Use [Sonner](https://sonner.emilkowal.ski/) with `richColors` | `bun add sonner`; [shadcn wrapper](https://ui.shadcn.com/docs/components/radix/sonner) where supported |
| Sidebar and login layouts | Start from [official shadcn blocks](https://ui.shadcn.com/blocks) | Choose the block for the project; use its documented install command |
| Tables and data grids | Use the Dice UI / [tablecn Data Grid](https://github.com/sadmann7/tablecn) with the full configuration below | `bunx --bun shadcn@latest add https://tablecn.com/r/data-grid.json` |
| Data-grid action bar | Always pair the grid with [Dice UI Action Bar](https://diceui.com/docs/components/base/action-bar) | `bunx --bun shadcn@latest add @diceui/action-bar` |
| Maps and geographic visualizations | Prefer [mapcn components and blocks](https://www.mapcn.dev/blocks) | Choose the block that fits the visualization and use its documented install command |
| Choropleth maps | Prefer mapcn's Choropleth block for comparing metrics across geographic regions | `bunx --bun shadcn@latest add @mapcn/choropleth` |
| General charting | Use [shadcn/ui Charts](https://ui.shadcn.com/docs/components/base/chart) as the default for chart components and dashboard visualizations; use Liveline for live charts and mapcn for maps | `bunx --bun shadcn@latest add chart` |
| Live and real-time charts | Prefer [Liveline](https://benji.org/liveline) for streaming metrics and continuously updating chart visualizations | `bun add liveline` |
| Calendar and activity heatmaps | Prefer [beUI Heat Calendar](https://beui.dev/charts/heat-calendar) for activity intensity over calendar dates | `bunx --bun shadcn@latest add @beui/heat-calendar` |
| File uploads | Use [Dice UI File Upload](https://diceui.com/docs/components/base/file-upload) | `bunx --bun shadcn@latest add @diceui/file-upload` |
| Image cropping | Use [Dice UI Cropper](https://diceui.com/docs/components/base/cropper) | `bunx --bun shadcn@latest add @diceui/cropper` |

### Expressive visual treatments

- Consider [Dither Kit](https://www.tripwire.sh/dither-kit) for a chart that
  should deliberately stand out, or for a playful, experimental site's visual
  direction. Use it selectively when the dithered aesthetic fits the brief;
  keep the component defaults above for ordinary product interfaces and charts.
- Preserve chart readability, labels, and contrast. Install only the chosen
  components, e.g. `bunx @dither-kit/cli add area-chart`;
  use `bunx @dither-kit/cli list` to inspect available components.

### Data-grid setup

Prefer a fully configured, feature-rich Dice UI Data Grid. Include the complete
applicable feature set by default; finish wiring controls to real behavior.
Install the grid and its add-ons from tablecn's direct registry URLs. Checked
2026-09-29: `@diceui/data-grid` resolves to a missing style-specific endpoint
(including `base-nova`); the direct tablecn items below resolve to Base UI code.
Keep the project's existing shadcn base/style and inspect compatibility before
adding these to a Radix project. Recheck registry resolution during setup.

Full setup for a Base UI project with shadcn already initialized:

```sh
bunx --bun shadcn@latest add \
  https://tablecn.com/r/data-grid.json \
  @diceui/action-bar \
  https://tablecn.com/r/data-grid-select-column.json \
  https://tablecn.com/r/data-grid-sort-menu.json \
  https://tablecn.com/r/data-grid-filter-menu.json \
  https://tablecn.com/r/data-grid-row-height-menu.json \
  https://tablecn.com/r/data-grid-view-menu.json \
  https://tablecn.com/r/data-grid-keyboard-shortcuts.json \
  https://tablecn.com/r/data-grid-skeleton.json \
  https://tablecn.com/r/use-data-grid-undo-redo.json
```

- Always pair every data grid with [Dice UI Action Bar](https://diceui.com/docs/components/base/action-bar).
  Wire it to row selection and the grid's applicable bulk actions.
- Configure search, multi-column sorting, typed filters, column visibility,
  pinning, resizing/auto-fit, and row-height controls with usable defaults.
- Include row/cell selection, relevant bulk actions, context menus, keyboard
  navigation, and the keyboard-shortcuts reference.
- For editable data, configure appropriate cell editors, validation, clipboard
  copy/paste, undo/redo, and supported row creation/deletion. Persist changes
  through the real API with saving, failure, and recovery feedback. Respect
  field permissions and use read-only mode where editing is inappropriate.
- Configure stable row IDs, virtualization, sensible column widths, loading
  skeletons, empty/no-results states, error/retry states, and responsive sizing.
- Preserve view preferences across visits and provide a reset. Integrate
  filtering/sorting with server queries for partially loaded datasets; follow
  the infinite-query preference above for large collections.
- Verify the enabled controls, keyboard interactions, persistence, and data
  states in the running UI. Explain any applicable feature left unconfigured.

### Forms and validation

- TanStack Form with shadcn/ui Field components; use the [integration guide](https://ui.shadcn.com/docs/forms/tanstack-form).
- [Zod](https://zod.dev/) for validation and inferred input types.
- Share input schemas where frontend and backend contracts genuinely match.
- Validate inputs on the server, including when client-side validation exists.
- Keep trivial forms simple; use form state tooling when it helps.
- For modal forms, prefer a shared responsive component using Drawer on mobile
  and Dialog on desktop.
- For Vaul-based mobile drawers, enable built-in background scaling with
  `shouldScaleBackground` and a `data-vaul-drawer-wrapper` around the page
  content. Keep overlay portals outside the wrapper, and verify the background
  returns to normal when the drawer closes.
- Preserve form state and focus across overlays. Protect unsaved changes and
  finish closing animations before navigation.

Overlay setup: [responsive Drawer/Dialog example](https://ui.shadcn.com/docs/components/base/drawer#responsive)
and [Dialog API](https://ui.shadcn.com/docs/components/base/dialog).
Install with `bunx --bun shadcn@latest add drawer dialog`.

### Date utilities

- Use [date-fns](https://date-fns.org/) for date parsing, formatting,
  comparisons, arithmetic, intervals, and relative-time utilities.
- Import the functions needed directly from date-fns. Use its existing
  utilities instead of implementing equivalent helpers.
- Handle time zones explicitly when relevant.
- Install with `bun add date-fns`.

## Backend and data

### Backend and APIs

- [Cloudflare Workers](https://developers.cloudflare.com/workers/) for runtime,
  [Hono](https://hono.dev/docs/getting-started/cloudflare-workers) for HTTP routing,
  and oRPC for typed APIs.
- Prefer Effect for substantial backend operations, dependency management,
  errors, cancellation, and resource lifecycles. Keep straightforward logic
  simple rather than wrapping every operation in an Effect service.
- Share browser-safe oRPC contracts across consumers. Keep database clients,
  authentication secrets, infrastructure, and backend implementations out of
  browser imports; server-only application modules may use backend packages.
- Add external REST/OpenAPI access, API documentation, and MCP only when the
  product needs them. Reuse shared contracts and backend operations across
  transports, and keep private interfaces out of public documentation.
- When API reference documentation is needed, prefer Scalar. Generate the
  OpenAPI specification from oRPC contracts or the project's existing generator;
  Scalar renders that specification as interactive documentation.
- Prefer serving Scalar within the application. A separate documentation site,
  package, hosting service, or publishing pipeline is optional.
- SDK generation is not a default. Add it or public package publishing only when
  separately requested.

| Use case | Docs | Setup |
| --- | --- | --- |
| Typed APIs | [oRPC getting started](https://orpc.dev/docs/getting-started) | Install compatible releases of `@orpc/server` and `@orpc/client` using the guide |
| Effect code | [Effect docs](https://effect.website/docs/) | Use the guide matching the selected release; for infrastructure, satisfy Alchemy's peer dependencies |

### Optional Scalar API reference

For a Hono application that already serves an OpenAPI document, install the
compatible `@scalar/hono-api-reference` integration and mount its middleware:

```ts
import { Scalar } from "@scalar/hono-api-reference";

// Example routes only; use the application's chosen reference and spec URLs.
app.get("/reference", Scalar({ url: "/openapi.json" }));
```

Here `app` is the existing Hono application and the document route already
exists. Keep the existing OpenAPI generator; do not add a second generator just
to render the reference. See [Scalar's Hono integration](https://scalar.com/products/api-references/integrations/hono).

### Database and storage

- Cloudflare D1 with Drizzle for small Cloudflare applications; use the
  [Drizzle + D1 guide](https://orm.drizzle.team/docs/sqlite/connect-cloudflare-d1).
- Keep schema and versioned migrations in the repository. Drizzle generates
  reviewed SQL; Alchemy applies committed migrations. Preserve database
  identities and migration history, with one authority for applying migrations.
- R2 for uploads, files and object storage.
- KV for caching or configuration that tolerates eventual consistency.
- Choose another database when transaction requirements, scale, features or
  existing infrastructure warrant it.

### Authentication

- [Better Auth](https://better-auth.com/docs/installation), with providers and
  plugins added according to product needs. Install with `bun add better-auth`.
- Use the [Drizzle adapter guide](https://better-auth.com/docs/adapters/drizzle)
  when using Drizzle.
- Use the [Better Auth CLI](https://better-auth.com/docs/concepts/cli) for schema
  generation. Match the runtime, plugins, CLI, and database adapter; apply
  generated schema changes through the project's existing migration workflow.
- Prefer same-origin integration and return Better Auth responses directly so
  their cookies and headers reach the browser. Use direct browser authentication
  and read-only server session checks when sufficient, avoiding a custom cookie
  forwarding layer. Verify refresh behavior for the selected integration.
- Choose providers and explicit account-linking rules according to product needs.

## Infrastructure and deployment

- Alchemy with Effect is mandatory for infrastructure.
- Use supported Alchemy resources to own provisioning, Worker bindings, secrets,
  cron, observability, and deployment configuration. Application code accesses
  resources through the resulting bindings. Prefer supported providers before
  custom provisioning and report gaps that require external setup.
- Keep Alchemy as the infrastructure and deployment source of truth. Avoid
  handwritten Wrangler configuration and competing deployment workflows;
  ignored configuration generated by underlying tools is acceptable.
- Start with one alchemy.run.ts in the infrastructure package; split modules
  when needed. See Repository structure for package placement.
- Prefer GitHub Actions deploying through Alchemy after checks pass for the
  exact commit being deployed. Use scoped credentials, keep production secrets
  out of untrusted pull-request jobs, and serialize production deployments
  without canceling a running migration or deployment.
- Use shared remote infrastructure state for CI and multiple deployers. Migrate
  existing state and verify resource ownership before switching deployment owners.
- Preserve deployment state and stable resource identities across deployments.

| Use case | Docs | Setup or command |
| --- | --- | --- |
| Alchemy setup | [Getting started](https://alchemy.run/getting-started/) | Follow the guide for the selected release, including Effect and platform peer dependencies |
| Infrastructure preview | [Alchemy CLI](https://alchemy.run/cli/) | `bun alchemy plan` |
| Deployment | [Alchemy CLI](https://alchemy.run/cli/) | `bun alchemy deploy` |

## Optional services

Add these only when the product needs them.

### Background jobs and coordination

- Queues for asynchronous background processing.
- Cron Triggers for scheduled work.
- Workflows for durable, multi-step jobs.
- Durable Objects for coordination or stateful real-time features.

### AI

- Prefer Workers AI when available models meet the task's quality and capability
  requirements. Use other providers when they are a better fit.
- AI Gateway when routing, observability, caching or rate limits are useful.
- Vectorize when vector search or retrieval is needed.
- Select models per task rather than maintaining a global default model.

### Email

- Cloudflare Email Service for transactional delivery when suitable.
- React Email for templates, with HTML and plain-text output.

### Logging and analytics

- evlog for structured application logging.
- Select the log destination and any dedicated error tracking per project.
- No global analytics provider is selected. Choose based on the need for basic
  traffic/performance metrics or product events, funnels and retention.
- Keep product analytics and operational logging as distinct concerns.

## Performance and agent readiness

- Target 100/100 in PageSpeed Insights / Lighthouse for Performance,
  Accessibility, Best Practices, and SEO on both mobile and desktop.
  Apply SEO checks to public, indexable pages; preserve intentional privacy
  and noindex behavior on private pages.
- Use Cloudflare's [web-perf skill](https://github.com/cloudflare/skills/tree/main/skills/web-perf)
  when building a new web app, making performance-relevant changes, and
  verifying release readiness. It is installed globally as `web-perf`.
- Audit representative routes and key user flows against a production build.
  Use PageSpeed Insights for public deployed URLs and local Lighthouse for
  local or authenticated pages. Run all four categories; a performance trace
  alone does not verify the other categories.
- Establish a baseline, diagnose measured bottlenecks, make focused changes,
  and rerun affected audits. Retain demonstrated improvements and revert
  regressions. Preserve required features, accessibility, and visual quality.
- Compare repeated final runs under consistent conditions and report the
  median and range rather than selecting the best run.
- Report tested URLs/routes, mobile and desktop scores, test conditions,
  and remaining blockers in the conversation. Treat anything below 100 as
  an unmet target requiring explanation; never claim a pass without results.
  If tools or access prevent measurement, report verification as incomplete.
- Check real-user Core Web Vitals when field data is available; distinguish
  field results from Lighthouse lab scores and report unavailable data honestly.

### Agent readiness

- For public applications, verify meaningful rendered HTML, crawlable
  documentation, canonical metadata, sitemap and robots behavior, and appropriate
  discovery links to OpenAPI and MCP where the product provides them.
- Provide machine-readable documentation and an `llms.txt` entry point where
  useful. Treat discovery files as aids, not proof that agents can use the product.
- Run [Is It Agent Ready](https://isitagentready.com/) against the deployed site,
  fix applicable findings, and rerun. Verify actual HTML and API/MCP behavior;
  report remaining blockers and inapplicable checks without adding irrelevant
  features solely to improve a score.
