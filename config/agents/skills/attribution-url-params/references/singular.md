# Singular

Singular parameters are query keys, not macros. Their values can be static or
filled by the ad platform. Tracking links use `p*` keys on `sng.link` or a
custom link domain. Website landing pages use `wp*` keys for the Web SDK.

## Parameters

### Tracking link parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `p` | Device platform. | `Android` | Android or iOS. |
| `pcid` | Campaign ID. | `123456789` | |
| `pcn` | Campaign name. | `summer_launch` | |
| `pscid` | Sub campaign ID. | `234567890` | Usually the ad set or ad group. |
| `pscn` | Sub campaign name. | `prospecting` | |
| `pcrid` | Creative ID. | `345678901` | May identify the network's ad or an individual creative. |
| `pcrn` | Creative name. | `video_a` | |
| `pshid` | Hashed or anonymized publisher app ID. | `publisher_hash` | |
| `psn` | Publisher app name. | `publisher_app` | |
| `psid` | Publisher app store ID. | `com.example.publisher` | |
| `pssn` | Placement name inside the publisher app. | `feed` | |
| `pssid` | Placement ID inside the publisher app. | `placement_123` | |
| `kw` | Search keyword. | `running_shoes` | |
| `paffn` | Affiliate name. | `affiliate_a` | |
| `paffid` | Affiliate ID. | `affiliate_123` | |
| `cl` | Click or transaction ID. | `ExampleClickID` | TikTok's template uses `__CALLBACK_PARAM__`. |
| `ip` | Device IP at click time. | `192.0.2.1` | Partner tracking. |
| `ua` | Complete device user agent. | User-agent string. | Partner tracking. |
| `ve` | OS version. | `26.0` | Numeric and decimal characters. |
| `idfa`, `ifa1`, `ifa5` | iOS advertising ID, raw, SHA-1, or MD5. | Advertising ID or hash. | Partner tracking. |
| `idfv`, `ifv1`, `ifv5` | iOS vendor ID, raw, SHA-1, or MD5. | Vendor ID or hash. | Partner tracking. |
| `aifa`, `aif1`, `aif5` | Android advertising ID, raw, SHA-1, or MD5. | Advertising ID or hash. | Partner tracking. |
| `oaid` | Open Anonymous Device ID. | Device identifier. | Used in China. |
| `amid` | Amazon advertising ID. | Advertising ID. | |
| `sng_ref` | Google Play install referrer. | Encoded referrer. | Server-to-server Android integrations. |

### Website parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `wpsrc` | Source or ad network. | `tiktok` | Partner templates supply the channel value. |
| `wpcid` | Campaign ID. | `123456789` | |
| `wpcn` | Campaign name. | `summer_launch` | |
| `wpscid` | Sub campaign ID. | `234567890` | |
| `wpscn` | Sub campaign name. | `prospecting` | |
| `wpcrid` | Creative ID. | `345678901` | |
| `wpcrn` | Creative name. | `video_a` | |
| `wpsn` | Site or placement name. | `feed` | |
| `wpkwn` | Search keyword. | `running_shoes` | |
| `wpkwid` | Keyword or target ID. | `kwd-123` | |
| `wpkmatch` | Keyword match type. | `e` | Value comes from the ad platform. |
| `an` | Ad network partner. | Partner identifier. | |

### Redirect and deep link parameters

Nested URLs and passthrough values are URL-encoded.

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `_dl` | Deep link for mobile platforms. | `myapp%3A%2F%2Foffer` | Requires deep linking enabled on the saved link. |
| `_ddl` | Deferred deep link. | `myapp%3A%2F%2Foffer` | Can enable deferred linking on the saved link. |
| `_ios_dl`, `_ios_ddl` | iOS deep link or deferred deep link. | `myapp%3A%2F%2Foffer` | Platform-specific. |
| `_android_dl`, `_android_ddl` | Android deep link or deferred deep link. | `myapp%3A%2F%2Foffer` | Platform-specific. |
| `_ios_redirect` | iOS destination when the app is absent. | Encoded App Store URL. | |
| `_android_redirect` | Android destination when the app is absent. | Encoded store URL. | |
| `_samsung_redirect` | Samsung store destination. | Encoded Samsung store URL. | Does not support deep linking. |
| `_fallback_redirect` | Destination for other platforms. | `https%3A%2F%2Fexample.com` | Usually a website. |
| `_global_redirect` | Destination for every platform. | `https%3A%2F%2Fexample.com` | Overrides other redirect destinations. |
| `_p` | Passthrough data for the app. | `summer_offer` | Plain string or encoded JSON. |
| `_forward_params` | Forwards link parameters to destinations. | `2` | `1` includes store and web fallback. `2` also includes the deep link. |
| `_force_redirect` | Uses an app scheme when Universal Links fail. | `1` | Requires an app-scheme deep link. |
| `redirect` | Controls redirecting after the click is recorded. | `false` | Partner sends the user to the store instead. |
| `_og_title`, `_og_desc`, `_og_image` | Social share preview overrides. | Encoded text or image URL. | Custom Source links only. |
| `force_ios_landing_page` | Forces an iOS social landing page. | Not specified. | Independent of the saved Enable Landing Page flag. |
| `force_android_landing_page` | Forces an Android social landing page. | Not specified. | Supported Meta apps only. Independent of the saved landing page flag. |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `referrer` | Forwarded referrer data, including Singular's click ID. | `singular_click_id%3Dexample` | The click ID is inside this value, not a separate top-level key. |

## Notes

- In web attribution, `utm_source` supplies Source when `wpsrc` is absent.
  `utm_campaign` supplies Campaign Name when `wpcn` is absent. Other UTMs
  remain UTM fields.
- Without `_forward_params`, UTM and referrer values pass to store and web
  fallback destinations. Custom keys need explicit forwarding.
- In TikTok Smart+, `pcrid` refers to the creative, not the ad bundle.
- Saved link settings also control destinations and deep linking. In-app
  browser support depends on the source app and destination.

## Sources

- [Tracking link parameters](https://support.singular.net/hc/en-us/articles/360018879491)
- [Creating website links](https://support.singular.net/hc/en-us/articles/360041317471)
- [Tracking links FAQ](https://support.singular.net/hc/en-us/articles/360030934212)
- [Deep link configuration](https://support.singular.net/hc/en-us/articles/360050910891)
