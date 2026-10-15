# Stack, vendors and foundation

## Tech stack

| Layer | Choice |
|---|---|
| Platforms | iOS + Android |
| Mobile | Expo (latest stable SDK) · React Native · Expo Router |
| App state | XState v6 · Effect atoms · TanStack Query |
| API | TypeScript 7 · Effect 4 · Effect HttpApi |
| Auth | Better Auth, wired per [Better Auth's Effect guide](https://better-auth.com/docs/integrations/effect): guest account first, then Apple and Google sign-in |
| Database | Postgres · Drizzle ORM (the fork's pinned version, 0.45 stable today) · PGlite locally and in tests |
| Infra as code | Alchemy |
| Monorepo | pnpm · Turborepo · Node 24 |
| Tooling | oxlint · oxfmt · ast-grep · Fallow · Vitest · lefthook · Renovate |
| Simulator and testing | Stim · agent-device |

## Paid vendors

| Need | Vendor |
|---|---|
| Hosting | Cloudflare (Workers, Workflows, R2, Images, Hyperdrive) |
| Database | PlanetScale Postgres |
| Builds and OTA updates | Expo EAS |
| Subscriptions and paywall | RevenueCat |
| Web payments (US) | Stripe, through RevenueCat Web Billing |
| Analytics and flags | PostHog |
| Crash reporting | Sentry |
| Install attribution | Singular |
| Ad networks | Meta · TikTok |
| Secrets | Infisical |
| Distribution | Apple Developer · Google Play |

## Versions

Effect 4, Alchemy and some other packages move fast and only certain versions work together. Don't install the latest of each and hope.

1. Keep the fork's lockfile and `pnpm-workspace.yaml` catalog. The pin decision record is `docs/adr/0002-pin-set.md`.
2. Upgrade Effect and Alchemy together, never separately. Move `drizzle-orm` and `drizzle-kit` together.
3. Keep one copy of `effect` in the dependency graph. Check with `pnpm why effect -r`.
4. Use Expo's bundled module versions for React, React Native and native modules.
5. Move to Drizzle 1.0 only once it's stable, as its own change. It differs from 0.45 in two places: relational queries use `defineRelations()` (relations v2), and each migration gets its own folder with no journal. Normal `select`/`insert`/`update`/`delete` code is the same. Arnold found 1.0 rc.4 crashing on newer Effect versions.

## Repo layout (from the Arnold fork)

| Path | Contents |
|---|---|
| `apps/native` | Expo app: thin screens, with vendor SDKs only in `lib/infra` adapters |
| `apps/server` | Cloudflare Worker host and `alchemy.run.ts`, with Hyperdrive pointed at PlanetScale (PGlite locally) |
| `packages/kernel` | Headless client state and logic, one folder per feature, with no React or native SDKs |
| `packages/contracts` | HttpApi schemas, shared with the app as types only |
| `packages/api` | Domain services and vendor ports: billing, webhooks, trial guard |
| `packages/db` | Drizzle schema, migrations and queries |
| `packages/cli` | The `app` command: `doctor`, `dev`, `sim`, `verify`, `acceptance` |
| `docs/` | `PRODUCT.md`, `decisions.md`, `human-checklist.md`, `setup/` (one file per vendor) |

`pnpm check` runs every gate: format, lint, types, tests, rules, dead code and workflows. CI and the pre-push hook run the same command. `pnpm app verify run <feature>/<recipe>` proves a behavior change and records evidence tied to the code, and `pnpm app verify check` fails when a changed feature has no current evidence.

Rewrite the repo's `AGENTS.md` for the new app during the foundation phase. `CLAUDE.md` points to it with `@AGENTS.md`.

**Why Effect HttpApi and not oRPC or Hono:** one schema, error and runtime model from the backend through the typed client, with no second error vocabulary to translate. The trade-off is a little more client setup than oRPC. If HttpApi breaks on React Native or Workers, fall back to oRPC instead of patching around the problem. Arnold's `docs/research/opinion-data-2026-09-30.md` has the full comparison.

## Rules learned in Arnold and Halo

- **One user ID everywhere.** The API creates a guest account on first launch, and that `userId` goes to every SDK before any of them starts.
- **Auth on the server.** Follow [Better Auth's Effect guide](https://better-auth.com/docs/integrations/effect), as Arnold does:
  - mount Better Auth's handler at `/api/auth/*` as a raw route next to the HttpApi (`HttpEffect.fromWebHandler`), with cross-origin set up as the guide shows
  - check sessions with `auth.api.getSession({ headers })` inside the HttpApi authentication middleware, and decode the user into a typed session or fail with `Unauthorized`
  - wrap Better Auth calls in a small Effect service that turns its Promises into Effects with a typed error
  - plugins: anonymous sign-in, plus Apple and Google
  - Drizzle owns the auth tables and their migrations, through the Better Auth Drizzle adapter
  - set `BETTER_AUTH_SECRET` explicitly and never rotate it casually, because a new secret logs out every user and strands guest accounts
  - don't use `@alchemy.run/better-auth`: it removes almost no code, needs Alchemy's own Worker style, uses camelCase columns, runs its own migrations and generates a new secret by default
- **Sessions on React Native.** Store the session cookie in SecureStore. Set `credentials: "omit"` and read `set-cookie` manually, because React Native has no `getSetCookie`.
- **RevenueCat owns who has Pro.** The app checks the `pro` entitlement. The server reads it through RevenueCat's REST API v2 with a short cache.
- **RevenueCat webhook:** `POST /webhooks/revenuecat`, authenticated with an `Authorization` header compared in constant time. Deduplicate by event ID.
- **Stripe webhook:** `POST /webhooks/stripe`, checking the signature against the signing secret.
- **Every vendor adapter has three modes:** `off`, `fake` and `live`, chosen by environment variables. Local development and tests run on `fake`.
- **Bind vendors in one place,** in a fixed order. Reset them on sign-out and erase them on account deletion. See Arnold's vendor identity decision record.

## Reference implementations

Read these when building the matching piece. Paths were checked on 2026-10-09; confirm they still exist.

**Arnold** ([github.com/productstudioinc/arnold](https://github.com/productstudioinc/arnold)):
- `docs/SCOPE.md`: overall design and the vendor table
- `docs/adr/0002-pin-set.md`: version pins
- `docs/adr/0010-vendor-identity.md`: user-ID binding across vendors
- `apps/native/lib/infra/revenuecat.ts`, `purchases.ts`, `attribution.ts`: RevenueCat and Singular adapters
- `packages/api/src/billing/Entitlements.ts`: server-side Pro check
- `packages/api/src/auth/Auth.ts`, `auth/better-auth.ts`, `http/routes.ts`: the Better Auth service, its config and the `/api/auth/*` mount, following the Effect guide
- `packages/api/src/http/routes.ts`: RevenueCat webhook
- `docs/setup/*.md`: per-vendor setup notes
- `.agents/skills/asc` and `.agents/skills/gpc`: App Store Connect and Google Play CLI workflows

**Halo** (`~/src/work/productstudioinc/halo`, private):
- `apps/server/src/webhooks/stripe.ts` and `docs/adr/0151-stripe-trial-guard-blocks-in-our-webhook.md`: Stripe trial guard
- `packages/api/src/singular/` and `docs/adr/0147-halo-owns-singular-purchase-feed.md`: Singular server-to-server fallback
- `apps/native/lib/attribution/providers/singular.ts`: Singular startup and ATT handling
