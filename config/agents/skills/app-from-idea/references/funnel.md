# Funnel, events, IDs and metrics

The flow below matches [../assets/funnel-diagram.png](../assets/funnel-diagram.png). Each arrow means one service sends data to another.

## Flow

1. **Ad → install.** The user taps a Meta or TikTok ad, which opens a Singular link. Singular records the click and redirects to the App Store or Google Play. The user installs.
2. **First launch.**
   - App → our API: create a guest account and get `userId` back.
   - The ATT prompt appears (iOS).
   - App → Singular: start the SDK with the ATT answer and `setCustomUserId(userId)`.
   - App → RevenueCat: `logIn(userId)`.
   - App → PostHog: `identify(userId)`.
3. **Onboarding → paywall.** App → PostHog: onboarding and paywall-view events. The app shows the RevenueCat paywall.
4. **Trial.** There are two paths:
   - **4a, in-app:**
     - The app starts the trial in the store.
     - The RevenueCat SDK sends the receipt, and RevenueCat verifies it.
     - Pro turns on.
     - RevenueCat → Singular: trial started.
     - Singular → Meta and TikTok: postback.
   - **4b, US web:**
     - The app opens a Web Purchase Link carrying `userId`.
     - RevenueCat starts the trial on Stripe and saves the card. Pro turns on.
     - Stripe → our API: webhook for the new trial.
     - If the card fingerprint already had a trial, our API cancels the new one in Stripe. Stripe → RevenueCat: the trial is cancelled and Pro turns off.
5. **Subscribe.**
   - **5a, in-app:** the store tells RevenueCat the trial converted. RevenueCat → Singular: subscribed + revenue. Singular sends a postback.
   - **5b, web:** Stripe tells RevenueCat the trial converted.
6. **Renew or churn.**
   - The store and Stripe → RevenueCat: renewed, payment failed or cancelled.
   - A failed payment starts a grace period, so Pro stays on while the store retries.
   - RevenueCat → Singular: renewal revenue.
7. **Measure.**
   - Meta and TikTok → Singular: ad spend, which gives return on ad spend.
   - RevenueCat → PostHog: all subscription events, which give the funnel and revenue.

Store updates are App Store Server Notifications V2 and Google Play RTDN, both sent to RevenueCat.

## Event map

| Funnel event | RevenueCat | Singular (rename in RevenueCat's integration) | Meta | TikTok | PostHog |
|---|---|---|---|---|---|
| Install | — | install (automatic) | Install | Install | `Application Installed` |
| Onboarding completed | — | — | — | — | `onboarding_completed` |
| Paywall viewed | — | — | — | — | `paywall_viewed` |
| Trial started | `INITIAL_PURCHASE` (trial period) | `sng_start_trial` | StartTrial | Start Trial | via RevenueCat |
| Trial converted | `RENEWAL` with `is_trial_conversion: true` | `sng_subscribe` + revenue | Subscribe (with value) | Subscribe | via RevenueCat |
| Paid without a trial | `INITIAL_PURCHASE` (normal period) | `sng_subscribe` + revenue | Subscribe (with value) | Subscribe | via RevenueCat |
| Renewed | `RENEWAL` | renewal revenue | — | — | via RevenueCat |
| Auto-renew turned off | `CANCELLATION` | — | — | — | via RevenueCat |
| Payment failed | `BILLING_ISSUE` | — | — | — | via RevenueCat |
| Subscription ended | `EXPIRATION` | — | — | — | via RevenueCat |

Rules:
- Meta and TikTok campaigns optimize on StartTrial, then Subscribe. Never on installs.
- Send revenue only on purchase events, in USD.
- Event names must match exactly across tools.

**To check:**
- RevenueCat's default event names for its Singular and PostHog integrations (they may be `rc_*`).
- The exact Meta and TikTok event names in Singular's partner settings.

## ID map

| ID | Created by | Used in |
|---|---|---|
| `userId` (our account ID) | Our API (Better Auth guest account on first launch) | RevenueCat `logIn`, Singular custom user ID, PostHog `identify`, the Web Purchase Link |
| Singular device ID | Singular SDK | Attribution and postbacks |
| IDFA / GAID | iOS (only if the user allows tracking) / Android | Singular device matching |
| Stripe customer ID | RevenueCat at web checkout | Stripe subscriptions and the Customer Portal |
| Card fingerprint | Stripe | The trial guard, stored by our API |
| Store transaction IDs | Apple / Google | Handled by RevenueCat only |

- Create `userId` before any SDK starts.
- Never use an email address as a vendor ID.
- When an account is deleted, also delete the user in RevenueCat and PostHog.

## Metrics

| Stage | Metric | Tool |
|---|---|---|
| Ad → install | CTR · CPI | Meta / TikTok · Singular |
| Onboarding → paywall | onboarding completion · paywall view rate | PostHog |
| Trial | trial start rate · cost per trial · web trials blocked | PostHog / RevenueCat · Singular · our API |
| Subscribe | trial conversion · cost per subscriber | RevenueCat · Singular |
| Renew or churn | monthly churn · recovered payments | RevenueCat |
| Measure | ROAS (day 7, day 30) · LTV | Singular · RevenueCat |
