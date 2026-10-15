---
name: portal
description: Route Product Studio and Halo work to Portal MCP tools instead of a browser. Use for team Discord servers, channels and conversations, such as "the engineering server". Use it for Slack, Gmail, Drive, Docs, Sheets, Calendar, Linear, Notion, GitHub, Vercel, Sentry, Axiom, PostHog and Expo too. It also covers App Store and Google Play reviews and releases, Singular installs and attribution, Stripe, RevenueCat and Superwall revenue, Meta, TikTok, Google, Apple, Snapchat, Pinterest, X and OpenAI ad campaigns, Zernio and Doublespeed social posts, COPS creator videos, Documenso signatures, QuickBooks books, Mercury banking, Warp payroll, Quo customer texts, Stable company mail and fal image generation. Also use to connect Portal, fix its setup, or show what a team can do with it.
---

# Portal

Portal is one MCP server at `https://mcp.product.studio/mcp` that exposes the
company's services. Tools are named `<service>_<tool>`, such as
`discord_read_messages`. Clients may add a prefix, such as `mcp__portal__`.

## Rules

- Use Portal tools for these services. Do not open a browser or the service's
  website instead.
- Tools may load on demand. Search for the service's tools before deciding they
  are missing.
- If no Portal tools are available, follow [setup](references/setup.md).
- If one service is missing, call `portal_list_servers`. Enable a disabled
  server with `portal_toggle_single_server`. If the service is not listed, the
  user lacks access. Look up which team has it in [teams](references/teams.md)
  and tell the user.
- Some services have only `_search` and `_execute` tools. Search the service's
  API spec first, then execute the request.
- Read before writing. Confirm sends, posts, deletions and payments with the
  user first.

## Pick the service

| The user mentions | Service |
|---|---|
| Discord, a server, channel, convo, standup, daily update | `discord` |
| Slack | `slack` |
| Email, Drive, Docs, Sheets, Calendar, meetings | `google-workspace` |
| Tickets, issues, projects, cycles | `linear` |
| Wiki pages, meeting notes | `notion` |
| Repos, pull requests, commits, CI | `github` |
| Code examples in public repos | `grep` |
| Deploys, preview URLs | `vercel` |
| Workers, DNS, R2, D1 | `cloudflare` |
| Railway services | `railway` |
| Errors, crashes | `sentry` |
| Logs | `axiom` |
| Product analytics, funnels, events | `posthog` |
| App builds, TestFlight, EAS | `expo` |
| App Store, Google Play, store reviews, prices | `store-apple`, `store-google` |
| Installs, attribution | `singular` |
| Revenue, subscriptions, trials, churn | `stripe`, `revenuecat` |
| Paywalls, paywall experiments | `superwall` |
| Ad campaigns, ad sets, spend, CPA | `<platform>-ads`, such as `meta-ads` or `tiktok-ads` |
| Blended ROAS, pLTV | `campaignswell` |
| Social posts, scheduling, comments, DMs | `zernio` |
| Organic content drafts, slideshows | `doublespeed` |
| Creators, creator videos | `cops` |
| Contracts, signatures | `documenso` |
| Books, invoices, expenses | `quickbooks` |
| Bank balance, transactions | `mercury` |
| Payroll | `warp` |
| Customer calls, texts | `quo` |
| Company mail, checks | `stable` |
| Image and video generation | `fal` |
| Databases, SQL | `planetscale` |

Send chat and channel requests to Discord unless the user names Slack.

## Discord

- **Product Studio Inc** is the team server. Its categories include chat,
  engineering, marketing, business and updates. The chat category holds
  general, standup and daily-update. "The engineering server" means the
  engineering category.
- **Halo AI - UGC** is the creator community.

List the server's channels, keep those under the named category, then read each
one's recent messages. Take channel IDs from that list each time instead of
reusing old ones.
