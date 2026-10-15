# X Ads

X ad destinations can carry static UTM parameters. X also appends a click ID
for conversion measurement. The sources below do not publish a general
campaign or ad URL macro catalog.

## Parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `utm_*` | Advertiser-supplied campaign labels. | `utm_source=x&utm_medium=paid_social` | Static values. Definitions are in [the skill](../SKILL.md#shared-utm-parameters). |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `twclid` | X click ID. | Opaque click ID. | Preserve the received value through redirects. |

## Notes

- X Pixel reads `twclid` from the URL or a first-party cookie. The click ID
  can also be supplied to the Conversions API.
- Conversion event fields such as `conversion_id`, `value`, and `currency`
  are event data, not ad URL macros.
- A conversion event's URL matching rule is separate from campaign tagging.
  Query parameters can make exact-URL matching brittle.

## Sources

- [Website conversion tracking and click IDs](https://help.x.com/en/business-and-advertising/conversion-tracking-for-websites)
- [Website traffic measurement](https://business.x.com/en/advertising/campaign-types/website-traffic)
