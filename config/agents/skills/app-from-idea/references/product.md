# Product: from idea to spec

Write `PRODUCT.md`. Keep it to one screen. It should cover:

- **Value:** one sentence on what the user gets, and why they would pay weekly.
- **Target user:** who they are and when they open the app.
- **Core loop:** the one action users repeat. Build only this for launch. Everything else goes in a "later" list.
- **Onboarding:** 3–7 screens. Show the value, ask a few personalization questions that make the paywall feel earned, then end on the paywall.
- **Paywall moment:**
  - the end of onboarding
  - the point where a free user hits a limit
  - Settings → Upgrade
- **Name:**
  - Short and easy to search.
  - Check `.com` availability and USPTO trademarks with the instant-domain-search tools.
  - Check for App Store name collisions.
  - Buying a domain needs approval.
- **Store listing draft:** name (30 characters max), subtitle (30), keywords (100), and the first lines of the description.

## Paywall defaults

| Plan | Price | Trial |
|---|---|---|
| Weekly | $8.99 | 3-day free trial |
| Yearly | $29.99 | none |

- Preselect the weekly trial. Show the yearly plan's savings compared with weekly.
- Use the same products and trial on the US web checkout.
- Record any change to these defaults in `docs/decisions.md` with the reason.

## Design

- **Native look:** use Apple's Human Interface Guidelines and native components (Expo UI, SF Symbols, haptics) where they fit.
- **Design tokens** for color, spacing, radius and type. No raw values in screens.
- **Light and dark** modes from day one.
- **Screenshots:** capture both simulators at each phase gate, so design problems show up early.
