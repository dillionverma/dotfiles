---
name: app-from-idea
description: Build and launch a subscription mobile app (iOS + Android) end to end from just an app idea, using Dillion's default stack, vendors, paywall and growth setup. Use when asked to build, ship, or launch a new app from an idea, or to set up a new app's stack, billing, attribution or store launch the "usual way".
metadata:
  author: dillion
  version: "1.0.0"
---

# App from idea

**Input:** an app idea. One sentence is enough.

**Output:**
- a working subscription app, approved and live on the App Store and Google Play
- billing, attribution, analytics and ads all connected
- `docs/decisions.md`, recording every choice made along the way

## Defaults (don't ask)

| Area | Default |
|---|---|
| Stack and vendors | [references/stack.md](references/stack.md) |
| Repo | A fork of [productstudioinc/arnold](https://github.com/productstudioinc/arnold), renamed and stripped of Arnold's own features. Follow [references/fork.md](references/fork.md) |
| Platforms | iOS and Android launch together |
| Paywall and billing | RevenueCat Paywalls + entitlements, with one entitlement named `pro`. No Superwall |
| Pricing | **$8.99/week with a 3-day free trial**, and **$29.99/year** |
| US web checkout | RevenueCat Web Purchase Links on Stripe, with the same trial, plus a trial-abuse guard: a Stripe webhook → our API, which cancels a trial if the card has had one before |
| Attribution | Singular, with Meta + TikTok as the ad networks. Ads use Singular redirect links to the stores. Show the ATT prompt on **first launch**, before Singular starts |
| Analytics and errors | PostHog and Sentry |

Decide everything else yourself (name, design, onboarding, copy, features) and log each decision with its reason in `docs/decisions.md`.

## Stop and ask before

- spending money: domains, paid plans, ad budgets, launching ads
- deleting anything outside the repo

Everything else is pre-approved. That includes creating free vendor projects, repos, store listings and Singular links, and submitting to and releasing on the App Store and Google Play.

Batch these into one request per phase instead of asking one at a time.

Some steps only the user can do: account-holder actions, 2FA, bank and tax details, legal agreements, and Apple's Retention Messaging request form. List them in `docs/human-checklist.md`. Keep building with each vendor adapter in fake or off mode until its keys arrive, so these never block the build.

## Phases

Each phase must end in a state you can verify. Don't start the next phase until the current one checks out.

1. **Product.** Follow [references/product.md](references/product.md).
   Done when `PRODUCT.md` covers the value, target user, core loop, onboarding, paywall moment and name, and the name has been checked for domain and trademark conflicts.
2. **Foundation.** Fork and rename Arnold, then remove its features, following [references/fork.md](references/fork.md).
   Done when no Arnold feature remains, the repo's `AGENTS.md` describes the new app, `pnpm check` passes, and the app runs on an iOS simulator and an Android emulator against the local API and PGlite.
3. **Core feature.** Build the core loop end to end.
   Done when it works in both simulators, verified by actually using the app, and its tests pass.
4. **Monetization and funnel.** Follow [references/funnel.md](references/funnel.md).
   Done when all of these work:
   - guest account → paywall → trial → Pro, in store sandboxes on both platforms
   - web trial in Stripe test mode
   - the guard blocks a second trial on a card that already had one
   - events show up in PostHog and in Singular's testing console
5. **Vendor setup.** Follow [references/setup.md](references/setup.md).
   Done when every item is either checked off or listed in `docs/human-checklist.md` with an owner.
6. **Store and ads launch.** Follow [references/launch.md](references/launch.md).
   Done when:
   - both apps are approved and released
   - Singular links are live
   - Meta and TikTok campaigns are ready (set the budget and go live only with approval)
   - a metrics dashboard exists

[assets/funnel-diagram.png](assets/funnel-diagram.png) shows the full funnel and how the vendors connect. Share it with anyone who needs the big picture.

## Long unattended runs

The first full build (Wallpapery) stalled twice:
- **Waiting on a dead agent.** Never end a turn waiting for a subagent's report unless a background agent or command is actually running. Check before stopping. A report a subagent asked for can come back to you instead of the subagent, and the subagent won't resume by itself.
- **Rate limits.** A provider rate limit (`429`, no eligible account) kills subagents mid-task. Before restarting them, check what each one left uncommitted in its working tree. Keep `bb pool status` healthy, and refresh any account in an error state with `bb pool account refresh <id>`.

## Unverified (test early and fall back if wrong)

- **RevenueCat → Singular events.** Trial and subscribe events reach Singular through RevenueCat's integration. Halo found this unreliable and replaced it with its own forwarder: RevenueCat webhook → our API → Singular server-to-server events. Use that approach if the integration fails.
- **Web trials in Stripe.** RevenueCat Web Billing trials on Stripe should fire `customer.subscription.created`, and a cancellation made in Stripe should flow back to RevenueCat.
- **Web purchases in Singular.** Unconfirmed whether they reach Singular. If they don't, measure the web funnel in PostHog.
- **Stripe Managed Payments.** Unconfirmed whether it works with RevenueCat Web Billing. Default to a regular Stripe account.

## Finish

Report:
- store links and the repo
- what's live, and what's still in fake mode
- remaining items in `docs/human-checklist.md`
- links to the metrics dashboards
- the decision log
