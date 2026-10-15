# Meta Ads

Meta replaces `{{...}}` macros in an ad's URL parameters. For App promotion,
dynamic parameters go on the deferred deep link.

## Parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{{campaign.id}}` | Campaign ID. | `123456789` | |
| `{{campaign.name}}` | Campaign name at first publish. | `summer_launch` | Later renames do not change the value. |
| `{{adset.id}}` | Ad set ID. | `234567890` | |
| `{{adset.name}}` | Ad set name at first publish. | `prospecting` | Later renames do not change the value. |
| `{{ad.id}}` | Ad ID. | `345678901` | |
| `{{ad.name}}` | Ad name at first publish. | `video_a` | Later renames do not change the value. |
| `{{placement}}` | Placement where the click occurred. | `instagram_stories` | Outputs for placements absent from Meta's list are undocumented. |
| `{{site_source_name}}` | Platform where the click occurred. | `ig` | `fb` Facebook, `ig` Instagram, `msg` Messenger, `an` Audience Network, `th` Threads. |
| `{{media_type}}` | Media type of the delivered catalog item. | Not specified. | Advantage+ catalog ads only. Output values are undocumented. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `fbclid` | Meta click ID. | `IwARexample` | Case-sensitive. Preserve the received value. |

## Notes

- Parameters in the URL parameters field override duplicate keys in the
  Website URL. They apply to paid ad clicks, not organic clicks on the post.
- API URL tags document the six ID and name macros. Support for placement,
  site source, and media type through the API is unconfirmed.
- `_fbc` and `_fbp` are cookies, not URL parameters.
- Editing a published ad's URL parameters may restart ad set learning.
- Catalog product tags and account-level audience-type tags are separate
  features. Their syntax and setup are in the sources below.

## Sources

- [Add URL parameters](https://www.facebook.com/business/help/1016122818401732)
- [Dynamic URL parameter specifications](https://www.facebook.com/business/help/2360940870872492)
- [API URL tags](https://developers.facebook.com/documentation/ads-commerce/instagram/ads-api/guides/url-tags-for-tracking)
- [Click ID and cookies](https://developers.facebook.com/documentation/ads-commerce/conversions-api/parameters/fbp-and-fbc)
- [Catalog product tags](https://developers.facebook.com/documentation/ads-commerce/marketing-api/advantage-catalog-ads/get-started)
- [Audience-type URL parameters](https://developers.facebook.com/documentation/ads-commerce/marketing-api/advantage-shopping-campaigns/audience-type-url-parameters)
