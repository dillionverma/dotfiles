# Vendor setup checklist

Mark each item done or move it to `docs/human-checklist.md` with an owner. Items marked (human) need the account holder. Creating accounts or anything public needs approval first.

## Apple (App Store Connect)
- [ ] (human) Developer Program membership, the Paid Apps agreement, and bank and tax details.
- [ ] App ID with In-App Purchase, Sign in with Apple, Associated Domains and Push turned on.
- [ ] A subscription group with the weekly plan ($8.99 with a 3-day free trial as its introductory offer) and the yearly plan ($29.99).
- [ ] Billing Grace Period on (Features → In-App Purchases).
- [ ] An In-App Purchase key (.p8), uploaded to RevenueCat.
- [ ] App Store Server Notifications V2 pointed at RevenueCat's URL, for both production and sandbox.
- [ ] A Sign in with Apple key for Better Auth.
- [ ] An App Store Connect API key for EAS and the `asc` CLI.
- [ ] The ATT prompt text (`NSUserTrackingUsageDescription`), SKAdNetwork IDs for Meta and TikTok, and Singular's postback endpoint.
- [ ] App Privacy answers covering every SDK.
- [ ] (human) Enroll in the App Store Small Business Program, which cuts Apple's commission from 30% to 15% for the first $1M of yearly revenue.
- [ ] Optional: (human) request access to the Retention Messaging API using RevenueCat's endpoint, then contact RevenueCat support. Neither Halo nor Arnold uses it yet. Halo uses RevenueCat Customer Center for retention offers instead.

## Google Play Console
- [ ] (human) Developer account and payments profile.
- [ ] Create the app and upload a first build to internal testing. Play won't let you create products without one.
- [ ] Subscriptions: a weekly base plan with a 3-day free-trial offer, and a yearly base plan.
- [ ] Grace period and account hold on.
- [ ] A service account with financial-data access; upload its JSON key to RevenueCat.
- [ ] Real-Time Developer Notifications using the Pub/Sub topic RevenueCat gives you.
- [ ] OAuth client IDs (Android, iOS, web) for Google sign-in, plus the SHA-256 fingerprints for `assetlinks.json`.
- [ ] The Data Safety form.

## RevenueCat
- [ ] A project with the iOS and Android apps, using the store credentials above.
- [ ] Import the products, create the `pro` entitlement, and set up a `default` offering with the paywall.
- [ ] Set restore behavior to "Transfer to new App User ID".
- [ ] Customer Center, with a retention offer shown when a user tries to cancel.
- [ ] Web Billing → connect Stripe and import the web products with a 3-day trial.
- [ ] A Web Purchase Link for the offering.
- [ ] A v2 secret key with customer read access, for the server's Pro check.
- [ ] A webhook to `/webhooks/revenuecat` with an Authorization value, for both sandbox and production.
- [ ] The Singular integration on, with events renamed per the event map.
- [ ] The PostHog integration on.

## Stripe
- [ ] (human) Business verification and live mode.
- [ ] Billing → Manage failed payments: Smart Retries on, cancel the subscription after the last retry, and failed-payment emails on.
- [ ] Customer Portal on.
- [ ] A webhook to `/webhooks/stripe` for `customer.subscription.created`, plus its signing secret.

## Our API (trial guard)
- [ ] On a new trial, read the card fingerprint.
- [ ] If that fingerprint already had a trial, cancel the subscription in Stripe and record the block.
- [ ] Store every fingerprint used for a trial.
- [ ] A test proving that a second trial on the same card gets cancelled.

## Singular
- [ ] Add the iOS and Android apps and get the SDK key and secret.
- [ ] Turn on SKAdNetwork / AdAttributionKit managed conversion values.
- [ ] Connect Meta and TikTok as partners, with postbacks (event mapping) and cost data.
- [ ] A link domain, and one Singular redirect link per campaign.

## Meta and TikTok
- [ ] (human) Business and ad accounts, payment method, and app ownership.
- [ ] Register the app in Meta Events Manager and TikTok Events Manager, with Singular as the attribution partner.

## PostHog
- [ ] A project and key.
- [ ] Autocapture off and session replay off by default.
- [ ] A personal key with `person:write`, used to erase users on account deletion.
- [ ] The app events from the event map.
- [ ] A funnel insight: install → onboarding completed → paywall viewed → trial started → subscribed.

## Platform
- [ ] **Cloudflare:** an account and API token for Alchemy, with staging and production stages.
- [ ] **PlanetScale:** a production Postgres database with point-in-time recovery, connected as the Hyperdrive origin.
- [ ] **Infisical:** a project with dev, staging and production environments, and a machine identity for deploys.
- [ ] **Sentry:** two projects (React Native and Workers), DSNs, and an auth token for uploading source maps.
- [ ] **Expo EAS:** a project, build profiles (development, preview, production) and update channels.
- [ ] **Web pages** served by the Worker: privacy policy, terms, account-deletion request, the apple-app-site-association file and `assetlinks.json`.
