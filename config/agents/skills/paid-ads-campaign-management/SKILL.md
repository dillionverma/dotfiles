---
name: paid-ads-campaign-management
description: Plan, create, edit, audit, and report on paid advertising campaigns, ad sets, ads, budgets, targeting, conversion optimization, and attribution across advertising platforms.
---

# Paid ads campaign management

## Language and definitions

Platform terminology varies. Map these concepts to the actual API fields rather
than assuming every platform has the same hierarchy or behavior. Use **ad set**
generically in this skill, and the platform's native term when operating its tools.

| Term | Meaning |
|---|---|
| Campaign | Top-level advertising container, usually defining the platform objective and sometimes a shared budget. |
| Ad set / ad group | Middle level controlling an audience and delivery settings. Platforms use different names and distribute these controls differently. |
| Ad | Deliverable advertising unit connecting creative, destination, identity, and tracking. An ad can contain multiple creative assets. |
| Creative / asset | The image, video, text, or other material shown in an ad. Separate from the ad object and its ID. |
| Business goal | The outcome the advertiser wants, such as trials or paying subscribers. |
| Campaign objective | The platform's selected campaign category, such as traffic, leads, or sales. |
| Event | A recorded action, such as registration, trial start, or purchase. |
| Conversion | An action designated as a desired result. Specify which event and counting method. |
| Optimization event | The event the delivery system tries to generate. It may differ from the ultimate business goal. |
| Deep-funnel event | A later action, such as subscribing after registration. Whether it influences delivery depends on the platform configuration. |
| Attribution | Rules for assigning conversion credit to advertising interactions. |
| Attribution window | How long after a click or view a conversion can receive credit. Separate from the reporting date range. |
| Destination | Where someone goes after clicking, potentially through redirects or deep links. |
| Tracking callback | A separate notification to a measurement provider; not necessarily part of the user's navigation. |
| Configured status | Whether an object is switched on or off. |
| Delivery status | Whether it can actually serve, accounting for review, schedules, budgets, and other restrictions. |

### Abbreviations

These are naming and reporting conventions, not interchangeable platform API enums.

| Abbreviation | Meaning |
|---|---|
| CBO / ABO | Campaign-level shared budgeting / ad-set-level budgeting. |
| HV | Naming shorthand for volume-focused bidding without an explicit cost or ROAS target. |
| CC / BC | Cost cap or target CPA / bid cap. These are different controls; even cost caps and target CPA strategies can have different platform semantics. |
| CPA | Spend divided by the specified acquisition or conversion count. |
| CPI | Spend divided by installs. |
| ROAS | Attributed revenue divided by ad spend. |
| CTR | Clicks divided by impressions; specify which click metric. |
| CVR | Conversion rate; always state the numerator and denominator. |
| 7DC / 1DV | Seven-day click / one-day view attribution. |
| MMP | Mobile measurement partner, used for mobile attribution and measurement. |

## Establish the intended outcome

Translate the request into:
- Business outcome: acquisition, leads, trials, purchases, retention.
- Audience and destination.
- Optimization event and success metric.
- Budget, schedule, and attribution settings.

Distinguish business goals from platform objectives and optimization events.
A campaign named for trials may optimize for registration; report the actual
configuration clearly.

Use existing context and authorization. Ask only when a missing decision
materially changes spend, targeting, measurement, or the requested outcome.

## Inspect before changing

Verify the account, currency, timezone, and target object IDs.
Read current configuration and discover the supported API operations.

Treat campaign, ad-set, ad, and creative objects as distinct. Names help humans
navigate; IDs establish which objects are affected.

Preserve settings outside the requested scope. When duplicating, compare the
resulting objects with the source rather than assuming defaults match.

## Naming

Follow an established naming convention when one exists. Check documented
conventions rather than assuming every existing name is correct.

Otherwise, use a compact, consistent structure:

Campaign:
`<PLATFORM>_<GEO>_<GOAL>_<BUDGET-MODE>_<BID-STRATEGY>_<PHASE>`

Ad set or ad group:
`<PLATFORM>_<OBJECT-TYPE>_<GEO>_<GOAL>_<AUDIENCE>`

Ad:
`<DATE>_<FORMAT>_<CREATIVE-IDENTIFIER>[_vN]`

Examples:
- `TT_US_TRIAL_CBO_HV_TEST`
- `TT_AG_US_TRIAL_BROAD`
- `2026-10-01_VIDEO_creator_12345678`

Include OS, placement, or other dimensions only when they help distinguish
meaningful variants. Define abbreviations and use them consistently.

Use the correct entity level:
- Campaign: business goal and budget strategy.
- Ad set: audience and delivery strategy.
- Ad: creative identity and version.

Avoid stuffing names with every setting. Names describe configuration;
they do not enforce it.

Use a consistent date and timezone convention. Version labels should identify
meaningful creative revisions or relaunches.

Before renaming, check whether tracking, reports, or automations depend on names.
Preserve IDs and record consequential renames.

## Budget and delivery

Identify where budget is controlled and whether it is shared.
Distinguish daily budgets, lifetime budgets, spend limits, and bid caps.

When adding or duplicating objects, check the resulting total potential spend.
Do not assume a daily budget is a strict daily spending ceiling; verify the
platform's pacing rules.

Inspect parent and child enable states. Reactivating a campaign can reactivate
eligible children that were enabled beneath it.

For new setups, assemble and verify before activating when the platform supports
that workflow. Launch within the user's existing authorization.

## Optimization and attribution

Keep these concepts separate:
- Campaign objective.
- Primary optimization event.
- Secondary or deeper-funnel event.
- Conversion counting method.
- Click, view, and engaged-view attribution windows.

Verify event eligibility and signal availability. An event appearing in a
selector does not establish that it is receiving useful data.

Never silently substitute an event, objective, or attribution window.
Explain platform restrictions and the practical alternatives.

Treat locked settings as platform constraints. Do not assume pausing, deleting,
or duplicating an object will remove a restriction.

## Destinations and tracking

Distinguish:
- The destination the user opens.
- Redirect or deep-link routing.
- Third-party click and impression callbacks.
- Analytics parameters and dynamic macros.

Use the platform's documented macro syntax. Preserve unrelated parameters,
encoding, deep links, and tracking integrations.

Verify saved URLs across all affected ads. Where practical, validate a preview
or test journey. Distinguish configuration verification from proof that
attribution works end to end.

## Creative and duplication

Preserve source creative IDs, account identities, permissions, CTA, destination,
and tracking when requested.

Check whether copying preserves the original post and engagement or creates a
new creative object. Do not assume those outcomes are equivalent.

For experiments, define the comparison and change only the intended variables.
Treat observed performance differences separately from causal conclusions.

## Execute and verify

Use supported APIs or native tools. Reuse idempotency keys when available.

After timeouts or partial failures, read current state before retrying. Do not
create duplicate campaigns, ad sets, or ads through blind retries.

Verify writes with a fresh read. Check both configured status and effective
delivery status, including review, scheduling, budget, and rejection states.

Deletion, replacement campaigns, and changes to measurement semantics require
authorization covering those consequences. Do not ask again when the user has
already authorized the exact action.

## Reporting

Align date ranges, timezones, currencies, campaign scope, and attribution
definitions before comparing sources.

Distinguish:
- Total clicks from unique clickers.
- Downloads from first installs and redownloads.
- Event counts from unique people.
- Attributed conversions from observed conversions.
- Platform-reported revenue from backend revenue.

Calculate conversion rates and acquisition costs with explicit denominators.
Label missing, delayed, modeled, and unavailable data accurately.

Do not assume totals from ad platforms, attribution providers, stores, and
product analytics should match exactly.

## Completion

Report:
- What changed and which objects were affected.
- Budget, optimization, and attribution settings.
- Verification results.
- Any remaining review, delivery, or measurement limitations.

"Created," "enabled," "approved," and "delivering" are different outcomes.
