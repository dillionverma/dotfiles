# Pinterest Ads

Pinterest replaces `{...}` macros when an ad is served. Supported macros
depend on whether the URL is a destination or a third-party tracking URL.

## Parameters

### Destination URL macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{campaignid}` | Campaign ID. | `123456789` | |
| `{campaign_name}`, `{campaignname}` | Campaign name. | `summer_launch` | |
| `{adgroupid}` | Ad group ID. | `234567890` | |
| `{ad_group_name}`, `{adgroupname}` | Ad group name. | `prospecting` | |
| `{creative_id}`, `{adid}` | Pin promotion ID. | `345678901` | Identifies the promotion, not the organic Pin. |
| `{device}` | Device category. | `m` | `m` mobile, `t` tablet, `c` computer. |
| `{product_name}` | Product name. | `running_shoes` | Shopping campaigns. |
| `{product_id}` | Product ID. | `sku_123` | Shopping campaigns. |
| `{product_partition_id}` | Product group ID for the promoted campaign. | `456789012` | Shopping campaigns. |
| `{promoted_product_group_id}` | Product group ID in the Catalog section. | `567890123` | Shopping campaigns. |
| `{lpurl}` | Product feed landing page URL. | `https://example.com/product` | Shopping campaign structure. Encoded when placed after or inside a tracking URL. |
| `{unescapedlpurl}` | Product feed URL without encoding. | `https://example.com/product` | Shopping campaigns. |
| `{organic_url}` | URL supplied when the Pin was created. | `https://example.com/product` | Manually created collections ads outside the sales objective. |

### Additional tracking URL macros

These are documented for parallel click and impression counting.

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{campaign_id}` | Campaign ID. | `123456789` | Alias for `{campaignid}` on tracking URLs. |
| `{ad_group_id}` | Ad group ID. | `234567890` | Alias for `{adgroupid}` on tracking URLs. |
| `{ad_id}`, `{creativeid}` | Pin promotion ID. | `345678901` | Tracking URL aliases. |
| `{creative_name}` | Pin promotion name. | `video_a` | |
| `{itemid}`, `{item_id}` | Pin promotion item ID. | `456789012` | |
| `{insertionid}`, `{insertion_id}` | Pin promotion insertion ID. | `567890123` | Can be used as a cache buster. |
| `{device_platform}` | Mobile operating system. | `iOS` | `iOS`, `Android`, or empty. |
| `{publisher}` | Publisher name. | `Pinterest` | Fixed value. |
| `{timestamp}`, `{click_timestamp}` | Event timestamp. | Timestamp value. | Units are not specified in this reference. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `epik` | Pinterest click identifier. | `123abc456def` | Preserve the received value. `_epik` is a cookie, not the URL key. |

## Notes

- Macros do not expand in ad previews. Check the served ad URL.
- Pinterest does not support `{keyword}` in ad tracking links.
- Automatic query parameters do not overwrite values already in a destination
  URL or product feed. Performance+ automatic UTMs are configured at ad group level.

## Sources

- [Dynamic macros and tracking URL support](https://help.pinterest.com/en/business/article/third-party-and-dynamic-tracking)
- [Automatic URL parameters and precedence](https://help.pinterest.com/en/business/article/add-url-parameters-to-your-ads)
- [Pinterest click identifier](https://developer.pinterest.com/docs/track-conversions/track-conversions-in-the-api/)
