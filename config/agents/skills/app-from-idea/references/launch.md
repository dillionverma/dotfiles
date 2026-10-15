# Test, submit, launch

## Test plan (no real money)

| Area | How |
|---|---|
| iOS purchases | StoreKit sandbox account on TestFlight: trial, conversion, cancellation, restore, and a failed payment entering the grace period |
| Android purchases | Play internal testing with license testers: the same cases |
| Web | Stripe test mode: start a web trial, then try a second trial on the same card and confirm the guard cancels it and Pro turns off |
| RevenueCat | Sandbox events arrive at `/webhooks/revenuecat`, and the Pro status matches |
| Attribution | Singular testing console sees install, `sng_start_trial` and `sng_subscribe`. Meta and TikTok test events arrive |
| Analytics | PostHog shows the funnel events for a test user |
| App | Both platforms: onboarding, paywall, core loop, sign-in with Apple and Google, account deletion, light and dark mode, offline |

Use Stim and agent-device to drive the simulators, and keep screenshots as evidence.

## Store listing
- Screenshots for each required device size, plus an app icon.
- Name, subtitle, keywords, description and promotional text.
- Privacy policy and support URLs. App Privacy and Data Safety answers.
- Age rating.
- Review notes covering how to reach the paywall, plus any test account App Review needs.

Use the `asc` and `gpc` skills (from the Arnold repo) for metadata, screenshots and submission.

## Release (no approval needed)
1. Submit the iOS app for App Review and the Android app to production review.
2. Once approved, release with a phased rollout on iOS and a staged rollout on Android.
3. Ship JavaScript-only fixes as EAS updates. Native changes need a new store build.

## Ads launch (needs approval for the budget and to go live)
1. Create a Singular redirect link for each Meta and TikTok campaign.
2. Set campaigns to optimize on StartTrial. Start with a small daily budget per network.
3. For the first 72 hours, watch:
   - crashes (Sentry)
   - funnel drop-off (PostHog)
   - cost per trial (Singular)
   - trial starts (RevenueCat)
4. After the first trials convert, judge campaigns by cost per subscriber and day-7 ROAS. Expect weekly churn on the weekly plan.

## After launch
- A dashboard covering the metrics table in `funnel.md`.
- `docs/decisions.md` updated with what was learned.
- The "later" list in `PRODUCT.md` re-ranked by what the data shows.
