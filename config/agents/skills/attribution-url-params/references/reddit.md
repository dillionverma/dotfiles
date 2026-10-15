# Reddit Ads

Reddit documents `{{...}}` macros for click and impression tracker URLs.
Destination URLs can carry static UTMs; macro substitution there is not
confirmed by the tracker documentation.

## Parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{{ADVERTISER_ID}}` | Reddit advertiser ID. | `t2_example` | |
| `{{CAMPAIGN_ID}}` | Campaign ID. | `123456789` | |
| `{{ADGROUP_ID}}` | Ad group ID. | `234567890` | |
| `{{ADGROUP_NAME}}` | Ad group name. | `prospecting` | |
| `{{AD_ID}}` | Ad ID. | `345678901` | |
| `{{AD_NAME}}` | Ad name. | `video_a` | |
| `{{POST_ID}}` | Reddit post ID. | `t3_example` | |
| `{{CLICK_ID}}` | Reddit click ID. | `456789012` | For click tracking. |
| `{{IMPRESSION_ID}}` | Reddit impression ID. | `567890123` | For impression tracking. |
| `{{COUNTRY}}` | User's country code. | `US` | Two-letter code. |
| `{{OS_GROUP}}` | Operating system group. | `osgrp,IOS` | Preserve the group prefix. |
| `{{DEVICE_GROUP}}` | Device category. | `devgrp,PHN` | Preserve the group prefix. |
| `{{PLATFORM_GROUP}}` | Mobile or desktop platform. | `plt,MBL` | `plt,MBL` mobile, `plt,DSK` desktop. |
| `{{CACHEBUSTER}}` | Current Unix timestamp. | Timestamp value. | UTC. |
| `{{CREATIVE_H}}`, `{{CREATIVE_W}}` | Ad height and width. | `1080` | |
| `{{ADVERTISING_ID}}` | iOS or Android advertising ID. | Advertising ID. | Device-dependent. |
| `{{IOS_ADVERTISING_ID}}` | iOS advertising ID. | Advertising ID. | |
| `{{ANDROID_ADVERTISING_ID}}` | Android advertising ID. | Advertising ID. | |
| `{{DEVICE_OPT_OUT}}` | Advertising ID sharing opt-out status. | `1` | `1` opted out, `0` not opted out. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `rdt_cid` | Reddit click ID on the landing page URL. | Opaque click ID. | Preserve it through redirects. Third-party trackers may require explicit forwarding. |

## Notes

- Macros are case-sensitive. The supported table does not list
  `{{CAMPAIGN_NAME}}` or `{{CREATIVE_ID}}`.
- Tracker URLs and the ad destination URL are separate fields. Static UTMs
  use [the shared definitions](../SKILL.md#shared-utm-parameters).
- Reddit Pixel captures `rdt_cid` automatically. Server-side conversion
  events need the persisted value in `click_id`.
- CM360 wrappers need Reddit's documented click-ID forwarding suffix.
  Use the partner setup instructions rather than a generic redirect.

## Sources

- [Supported tracker macros](https://business.reddithelp.com/s/article/Set-up-third-party-measurement)
- [Click ID persistence and forwarding](https://ads-api.reddit.com/docs/v3/guides/programs/capi/click-id-persistence)
