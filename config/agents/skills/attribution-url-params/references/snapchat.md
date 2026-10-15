# Snapchat Ads

Snapchat replaces `{{...}}` macros in website URLs. Third-party tracking
URLs use a separate `~.~...~.~` syntax.

## Parameters

### Destination URL macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{{campaign.id}}` | Campaign ID. | `11111111-1111-4111-8111-111111111111` | |
| `{{campaign.name}}` | Campaign name. | `summer_launch` | |
| `{{adSet.id}}` | Ad set ID. | `22222222-2222-4222-8222-222222222222` | Called an Ad Squad in the API. Preserve `adSet` capitalization. |
| `{{adSet.name}}` | Ad set name. | `prospecting` | |
| `{{ad.id}}` | Ad ID. | `33333333-3333-4333-8333-333333333333` | |
| `{{creative.name}}` | Creative name. | `video_a` | |
| `{{creative.headline}}` | Creative headline. | `summer_sale` | |
| `{{site_source_name}}` | Site source name. | Not specified. | Output values are not defined in the macro list. |

### Third-party tracking macros

These belong in approved swipe-up and paid-impression tracking URLs.

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `~.~SERVER_ORG_ID~.~` | Organization ID. | Organization UUID. | |
| `~.~SERVER_AD_ACCOUNT_ID~.~` | Ad account ID. | Account UUID. | |
| `~.~SERVER_CAMPAIGN_ID~.~` | Campaign ID. | Campaign UUID. | |
| `~.~SERVER_AD_SQUAD_ID~.~` | Ad Squad ID. | Ad Squad UUID. | |
| `~.~SERVER_CREATIVE_ID~.~` | Creative ID. | Creative UUID. | |
| `~.~SERVER_AD_ID~.~` | Ad ID. | Ad UUID. | |
| `~.~SERVER_MOAT_PRODUCT_TYPE~.~` | Ad product type. | Product type value. | |
| `~.~TIMESTAMP~.~` | Timestamp for cache busting. | Timestamp value. | Use this syntax, not `[timestamp]`. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `ScCid` | Snapchat click ID. | `44444444-4444-4444-8444-444444444444` | Preserve the received key and value. Help examples also use `sccid` and `scCid`. |
| `snap_campaign_id` | Shopify integration campaign identifier. | Integration-generated ID. | Snapchat Ads App for Shopify only. Cannot be overwritten by the macro builder. |

## Notes

- Snap URL-encodes special characters in macro values. Snapcode previews use
  `successful_` placeholder values instead of live IDs.
- Website URL macros also work in the API's `web_view_properties.url`.
  Dynamic Ads `url_macro_parameters` uses bare expressions instead, such as
  `utm_campaign=campaign.id&utm_content=ad.id`.
- Snap's Dynamic Ads API examples disagree on ad-set name syntax.
  Check the generated URL before relying on that field.
- Tracking URLs must use approved domains. Their macro syntax is separate
  from destination URL macros.
- The Conversions API accepts the click ID as `sc_click_id`, or extracts it
  from the full `event_source_url`. `_scid` is a cookie, not the URL key.

## Sources

- [Ads Manager URL macros](https://businesshelp.snapchat.com/s/article/add-url-macros)
- [Website URL macro support](https://developers.snap.com/marketing-api/Ads-API/creatives)
- [Dynamic Ads query parameters](https://developers.snap.com/marketing-api/Ads-API/dynamic-product-ads)
- [Third-party tracking macros](https://developers.snap.com/marketing-api/Ads-API/ads)
- [Click ID handling](https://developers.snap.com/marketing-api/Conversions-API/UsingTheAPI)
- [Click ID troubleshooting](https://businesshelp.snapchat.com/s/article/troubleshooting-click-id)
