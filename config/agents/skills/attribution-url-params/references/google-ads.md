# Google Ads

Google replaces `{...}` ValueTrack macros at click time. The final URL suffix
adds query parameters to the landing page. A tracking template inserts the
landing page URL into a tracking URL.

## Parameters

### Campaign and targeting macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{campaignid}` | Campaign ID. | `123456789` | |
| `{adgroupid}` | Ad group ID. | `234567890` | Unavailable in Performance Max. |
| `{assetgroupid}` | Asset group ID. | `234567890` | Performance Max only. Suffix support is not explicitly documented. |
| `{creative}` | Ad ID. | `345678901` | Unavailable in Performance Max. |
| `{keyword}` | Matching account keyword. | `running%20shoes` | Blank for keywordless matches. Unsupported in Demand Gen and Performance Max. |
| `{matchtype}` | Keyword match type. | `e` | `e` exact, `p` phrase, `b` broad, `a` AI Max keywordless. Not Performance Max or Hotel. |
| `{targetid}` | ID of the target that triggered the ad. | `aud-456:kwd-123` | Prefixes include `kwd`, `kwl`, `dsa`, `aud`, `pla`, `hpi`. Not Performance Max, Demand Gen, or Hotel tROAS. |
| `{network}` | Network that served the ad. | `g` | `g` search, `s` search partners, `d` Display, `ytv` YouTube, `vp` video partners, `gtv` Google TV, `x` Performance Max, `e` non-search App engagement. Not Demand Gen. |
| `{device}` | Device category. | `m` | `m` mobile, `t` tablet, `c` computer. |
| `{devicemodel}` | Phone or tablet model. | `Apple+iPhone` | Display only. |
| `{placement}` | Content site or targeted placement. | `gmail.com` | Display and Video. Not Performance Max or Demand Gen. |
| `{target}` | Targeted placement category. | `%2Fentertainment` | Placement-targeted campaigns. Not Performance Max or Demand Gen. |
| `{loc_interest_ms}` | Targeted location of interest ID. | `1014044` | Returned when location of interest helped trigger the ad. |
| `{loc_physical_ms}` | Physical location ID. | `1014044` | Returned when the user's location helped trigger the ad. |
| `{extensionid}` | Clicked asset ID. | `456789012` | Not Display or Performance Max. |
| `{feeditemid}` | Clicked legacy feed asset ID. | `456789012` | Legacy. No value after asset migration. Not Display or Performance Max. |
| `{gclid}` | Google click ID. | `ExampleClickID` | May be empty for affected iOS traffic. |
| `{random}` | Random unsigned 64-bit number. | `987654321` | Commonly used as a cache buster. |
| `{param1}`, `{param2}` | Advertiser-defined creative parameters. | `sale` | Legacy AdParamService. Not Performance Max. |
| `{ignore}` | Marks the remaining URL as tracking information. | No value. | Final URL or final mobile URL only. Not a suffix or template macro. |
| `{_name}` | Advertiser-defined custom parameter. | `summer` | For example, `{_season}`. Defined below account level. |

### Conditional macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{ifmobile:[value]}` | Inserts text for a mobile click. | `mobile` | For example, `{ifmobile:mobile}`. |
| `{ifnotmobile:[value]}` | Inserts text for a computer or tablet click. | `desktop` | For example, `{ifnotmobile:desktop}`. |
| `{ifsearch:[value]}` | Inserts text for a Search Network click. | `search` | False in Performance Max. Unsupported in Demand Gen. |
| `{ifcontent:[value]}` | Inserts text for a Display Network click. | `display` | False in Performance Max. Unsupported in Demand Gen. |

### Tracking template macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{lpurl}` | Final landing page URL. | `https://example.com` | Unescaped at the start of a template, escaped elsewhere. |
| `{lpurl+2}` | Final URL escaped twice. | `https%253A%252F%252Fexample.com` | For nested redirects. |
| `{lpurl+3}` | Final URL escaped three times. | `https%25253A%25252F%25252Fexample.com` | For nested redirects. |
| `{unescapedlpurl}` | Final URL without escaping. | `https://example.com` | |
| `{escapedlpurl}` | Escaped final URL. | `https%3A%2F%2Fexample.com` | |
| `{escapedlpurl+2}` | Final URL escaped twice. | `https%253A%252F%252Fexample.com` | |
| `{escapedlpurl+3}` | Final URL escaped three times. | `https%25253A%25252F%25252Fexample.com` | |

### Shopping macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{adtype}` | Shopping ad type. | `pla` | Also `pla_multichannel`, `pla_with_promotion`, `pla_with_pog`. Limited Performance Max support. |
| `{merchant_id}` | Merchant Center account ID. | `123456789` | Limited Performance Max support. |
| `{product_channel}` | Product sales channel. | `online` | `online` or `local`. Limited Performance Max support. |
| `{product_id}` | Product ID from the feed. | `sku_123` | Limited Performance Max support. |
| `{product_country}` | Product country of sale. | `US` | Limited Performance Max support. |
| `{product_language}` | Product information language. | `en` | Limited Performance Max support. |
| `{product_partition_id}` | Product group ID. | `234567890` | Not Performance Max. |
| `{store_code}` | Local store ID. | `store_01` | Up to 60 characters. Not Performance Max. |

### Hotel macros

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `{hotelcenter_id}` | Hotel Center account ID. | `123456789` | Hotel campaigns. |
| `{hotel_id}` | Hotel ID from the feed. | `hotel_123` | Hotel campaigns. |
| `{hotel_partition_id}` | Hotel group ID. | `234567890` | Hotel campaigns. |
| `{hotel_adtype}` | Hotel or room bundle. | `Hotel` | `Hotel` or `Room`. |
| `{travel_start_day}`, `{travel_start_month}`, `{travel_start_year}` | Check-in date components. | `14`, `10`, `2026` | Values shown in the ad. |
| `{travel_end_day}`, `{travel_end_month}`, `{travel_end_year}` | Check-out date components. | `16`, `10`, `2026` | |
| `{advanced_booking_window}` | Days from click to check-in. | `3` | |
| `{date_type}` | Who selected the dates. | `selected` | `default` means Google chose them. |
| `{number_of_adults}` | Number of adults. | `2` | |
| `{price_displayed_total}` | Displayed total room cost. | `250` | User's currency. |
| `{price_displayed_tax}` | Displayed taxes and fees. | `25` | User's currency. |
| `{user_currency}` | Currency code. | `USD` | |
| `{user_language}` | Display language code. | `en` | |
| `{adtype}` | Travel ad type. | `travel_booking` | `travel_booking` or `travel_promoted`. |
| `{rate_rule_id}` | Conditional price rule ID. | `rate_123` | |

## Automatically added parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `gclid` | Google click ID. | `ExampleClickID` | Auto-tagging. Case-sensitive. |
| `gbraid` | Aggregate identifier for app conversion measurement. | `ExampleBraidID` | For affected iOS measurement. Case-sensitive. |
| `wbraid` | Aggregate identifier for web conversion measurement. | `ExampleBraidID` | For affected iOS measurement. |
| `gad_source` | Ad source identifier. | `1` | Numeric meanings are undocumented. Not customizable. |
| `gad_campaignid` | Campaign identifier for conversion measurement. | `123456789` | Equality with `{campaignid}` is unconfirmed. |

## Notes

- Google has no campaign, ad group, or ad name macros. Resolve names by ID.
- Unavailable macro values become empty. Parse compound `{targetid}` values by prefix.
- All landing page insertion macros belong in tracking templates. Templates
  at account, campaign, or ad group level require one. Dynamic Search Ads and
  auto-targets require one at every level.
- Final URL suffixes contain `key=value` pairs without a leading `?` or `&`.
  They cannot contain landing page insertion macros or `{ignore}`.
- Performance Max supports a subset. Shopping values depend on the channel
  and ad format. Its API support list includes `{product_feed_label}` without
  defining the output.
- App campaigns use ValueTrack with Confirmed-Installs third-party analytics.
  They do not follow ordinary auto-tagging behavior.
- The Video macro `{sourceid}` is listed without a definition. Other legacy and
  undefined macros are left to the official reference.

## Sources

- [ValueTrack parameter definitions](https://support.google.com/google-ads/answer/6305348)
- [Performance Max support](https://developers.google.com/google-ads/api/performance-max/valuetrack)
- [Custom parameters](https://support.google.com/google-ads/answer/6325879)
- [Auto-tagging](https://support.google.com/google-ads/answer/3095550)
- [Aggregate identifiers](https://support.google.com/analytics/answer/16479993)
