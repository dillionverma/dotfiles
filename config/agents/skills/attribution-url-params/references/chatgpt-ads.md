# ChatGPT Ads

ChatGPT Ads replaces `{...}` macros in landing page query parameters.
Static UTM values and dynamic ID macros can be combined in the same link.

## Parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{campaign_id}` | Campaign ID. | `cmpn_123` | |
| `{ad_group_id}` | Ad group ID. | `adgrp_123` | |
| `{ad_id}` | Ad ID. | `ad_123` | Product-feed ads identify the template ad, not an individual product. |
| `{ad_account_id}` | Ad account ID. | Account identifier. | |
| `{oppref}` | Click reference in a query template. | Opaque reference. | Shown in the developer tracking-template example. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `oppref` | OpenAI click reference. | Opaque reference. | Preserve the original value through redirects and when reporting conversions. |

## Notes

- Ads Manager calls the field Landing page query parameters. The API uses
  `landing_page_configuration.query_string_template`.
- Distinct query keys combine. Precedence resolves duplicate keys.
- Standard Ads Manager precedence is Ad URL, Ad, Ad Group, then Campaign.
  A key already in the Ad URL wins.
- Product-feed accounts have separate ordering. In the new mode, higher
  priority is Ad, Ad group, Campaign, Account, then Feed. Legacy mode puts
  Feed first. The developer guide requires migration by November 5, 2026.
- The Conversions API does not capture `oppref` automatically. It must
  receive the original click reference with the event.

## Sources

- [Ads Manager macros and precedence](https://help.openai.com/en/articles/20001214-measure-results)
- [API tracking parameters and product-feed ordering](https://developers.openai.com/ads/campaign-management#tracking-parameters)
- [Click reference and conversion measurement](https://developers.openai.com/ads/conversion-tracking)
