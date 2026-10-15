# TikTok Ads

TikTok replaces `__...__` macros in ad URLs. The campaign macros below also
appear in MMP tracking links. Other MMP macros belong in partner-generated
tracking URLs.

## Parameters

### Campaign macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `__CAMPAIGN_ID__` | Campaign ID. | `123456789` | |
| `__CAMPAIGN_NAME__` | Campaign name. | `summer_launch` | Name encoding is undocumented. |
| `__AID__` | Ad group ID. | `234567890` | This is the ad group, not the ad. |
| `__AID_NAME__` | Ad group name. | `prospecting` | Name encoding is undocumented. |
| `__CID__` | Ad ID in manual campaigns, creative ID in upgraded Smart+. | `345678901` | Smart+ creatives sit inside an ad bundle. |
| `__CID_NAME__` | Ad name in manual campaigns, creative name in upgraded Smart+. | `video_a.mp4` | Smart+ documentation describes the asset file name. |
| `__ADID_V2__` | Upgraded Smart+ ad bundle ID. | `456789012` | Documented for Ads Manager URL parameters. API support is unconfirmed. |
| `__ADID_V2_NAME__` | Upgraded Smart+ ad bundle name. | `summer_bundle` | Same support restriction as `__ADID_V2__`. |
| `__PLACEMENT__` | Placement where the ad appeared. | Not specified. | Exact output strings are undocumented. |

### MMP tracking macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `__CALLBACK_PARAM__` | Identifier returned to TikTok for attribution. | Partner-generated identifier. | TikTok's Singular example maps it to `cl`. |
| `__CALLBACK_URL__` | Alternative conversion callback macro. | Not specified. | Listed by TikTok, but its meaning and format are not defined. |
| `__IDFA__` | iOS advertising ID. | Advertising ID. | Availability depends on device permissions. |
| `__GAID__` | Android advertising ID. | Advertising ID. | |
| `__IP__` | Device IP address. | `192.0.2.1` | Partner tracking only. |
| `__UA__` | Device user agent. | User-agent string. | Partner tracking only. |
| `__SL__` | Meaning not defined by TikTok. | Not specified. | Partner examples map it to language fields. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `ttclid` | TikTok click ID on the landing page URL. | `E.C.P.example` | Preserve the full received value. |

## Notes

- Upgraded Smart+ has campaign, ad group, ad bundle, and creative levels.
  TikTok says the ad bundle level is not reported to MMPs.
- `__CLICKID__` is not a generally documented macro. For MMP links, use the
  partner template, including `__CALLBACK_PARAM__` where specified.
- TikTok's UTM auto-attach feature is separate from click-ID attachment.

## Sources

- [UTM parameters and supported campaign macros](https://ads.tiktok.com/help/article/track-offsite-web-events-with-utm-parameters?lang=en)
- [Upgraded Smart+ reporting levels](https://ads.tiktok.com/help/article/about-reporting-for-the-upgraded-smart-experience?lang=en)
- [Supported MMP macros](https://ads.tiktok.com/help/article/about-supported-macros-for-mobile-measurement-partners?lang=en)
- [MMP tracking link examples](https://ads.tiktok.com/help/article/mobile-measurement-partner-mmp-tracking?lang=en)
- [TikTok click ID](https://ads.tiktok.com/help/article/tiktok-click-id?lang=en)
