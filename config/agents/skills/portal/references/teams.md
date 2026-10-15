# What each team can do with Portal

Portal shows each person only the services their team groups can use. A person
can be in more than one group, so combine the matching sections. This list is a
snapshot; the source of truth is `packages/infra/src/portals.ts` and
`packages/infra/src/groups.ts` in the portal repository.

## Everyone

- **Google Workspace:** Drive, Docs, Sheets, Gmail, and Calendar.
- **Slack:** read and post messages in channels you are in.

Try:
- "Summarize what happened in #general today."
- "Find the latest doc about our launch plan in Drive."

## Marketing

- **Linear:** see and update team issues.
- **Notion:** read and edit pages you already have access to.
- **Discord:** read and manage the team and creator servers.
- **Zernio:** plan and schedule social posts.
- **COPS:** browse creator and video inventory.
- **Singular:** attribution reports on where installs come from.
- **Documenso:** prepare and send documents for signature.

Try:
- "Which of our TikTok posts did best this week?"
- "What posts are scheduled in Zernio for next week?"
- "What are the most common questions in Discord this week?"

## Operations

- **Linear:** triage and update issues.
- **Notion:** read and edit team pages.
- **Discord:** read and manage the team and creator servers.
- **Quo:** customer calls and texts.
- **Stable:** company mail and checks.

Try:
- "List new Linear issues nobody is assigned to."
- "Did any mail arrive in Stable this week?"
- "Show me unanswered customer texts in Quo."

## Monetization

- **Stripe, RevenueCat, and Superwall:** revenue, subscriptions, and paywall experiments.
- **App Store Connect and Google Play:** app prices, subscriptions, and store data.
- **Linear:** see and update team issues.

Try:
- "How much subscription revenue did we make last week?"
- "Which Superwall paywall experiment is winning right now?"
- "What does our yearly plan cost in each country on the App Store?"

## Finance

- **QuickBooks:** the company books.
- **Mercury:** bank balances and transactions.
- **Warp:** payroll.
- **Stripe, RevenueCat, and Superwall:** revenue and subscriptions.
- **App Store Connect and Google Play:** store revenue.
- **CampaignsWell and Singular:** ad spend, revenue, and return on ad spend.
- **Linear:** see and update team issues.

Try:
- "What's our current Mercury balance?"
- "Compare last month's Stripe revenue with what's in QuickBooks."
- "What was our return on ad spend last month?"

## Paid ads

- **Meta, Google, Apple, TikTok, Pinterest, OpenAI, Snapchat, and X Ads:** campaigns, budgets, and results.
- **CampaignsWell and Singular:** ad performance and attribution.
- **COPS and Zernio:** creator videos and social content.
- **Linear:** see and update team issues.

Try:
- "Which Meta campaigns spent the most yesterday, and what did they return?"
- "Show TikTok ads that were rejected this week."

## Engineering

- **GitHub and Vercel:** code, pull requests, and deployments.
- **Sentry and Axiom:** errors and logs.
- **PostHog:** product analytics.
- **Cloudflare, PlanetScale, and Railway:** infrastructure and databases.
- **Expo, App Store Connect, and Google Play:** app builds and releases.
- **Notion, fal, and Grep:** docs, image generation, and code search.

Engineering does not have Linear through Portal.

Try:
- "What are the top new Sentry errors since yesterday's deploy?"
- "Why did the last Vercel deployment fail?"

## Superadmins

Superadmins can use every service above.
