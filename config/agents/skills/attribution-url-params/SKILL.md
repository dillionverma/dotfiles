---
name: attribution-url-params
description: Look up attribution URL parameters and macros for TikTok, Meta, Google Ads, Snapchat, Pinterest, Reddit, ChatGPT Ads, X, Singular, the App Store, and Google Play. Use when choosing parameters for a tracking link or checking what an existing parameter means.
---

# Attribution URL parameters

Read the page for the platform or tracking service you are using. For an ad
link to Singular, read both pages. Tables use the same four columns throughout.
Example values are illustrative, not real account or click IDs.

## Definitions

- A parameter is a query key and value, such as `utm_source=tiktok`.
- A macro is a placeholder the ad platform replaces, such as `{{ad.id}}`.
  In `ad_id={{ad.id}}`, `ad_id` is your key and `{{ad.id}}` is Meta's macro.
- A click ID identifies ad interaction data. The platform adds it to eligible
  clicks, so preserve the received value through redirects.
- An MMP is a mobile measurement partner, such as Singular.

## Platforms

| Platform | Reference |
|---|---|
| TikTok Ads | [Macros, Smart+, and click IDs](references/tiktok.md) |
| Meta Ads | [Dynamic parameters and click IDs](references/meta.md) |
| Google Ads | [ValueTrack and auto-tagging](references/google-ads.md) |
| Snapchat Ads | [Destination macros, tracking macros, and click IDs](references/snapchat.md) |
| Pinterest Ads | [Destination macros, shopping, and tracking URLs](references/pinterest.md) |
| Reddit Ads | [Tracker macros and click IDs](references/reddit.md) |
| ChatGPT Ads | [Landing page macros and click references](references/chatgpt-ads.md) |
| X Ads | [Static UTMs and click IDs](references/x.md) |
| Singular | [Tracking link, website, and redirect parameters](references/singular.md) |
| Apple | [App Store campaign links and custom product pages](references/apple.md) |
| Google Play | [Store links, install referrers, and custom listings](references/google-play.md) |

## Shared UTM parameters

UTMs are query keys. Their values can be static text or a supported platform macro.

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `utm_source` | Traffic source. | `tiktok` | Platform or publisher. |
| `utm_medium` | Marketing channel. | `paid_social` | Use a consistent naming convention. |
| `utm_campaign` | Campaign name. | `summer_launch` | A name, not a reliable ID for joins. |
| `utm_id` | Campaign ID. | `123456789` | Can receive a campaign ID macro. |
| `utm_content` | Distinguishes ads or creative variants. | `video_a` | Can receive an ad ID or name macro. |
| `utm_term` | Search keyword or targeting label. | `running_shoes` | Meaning depends on your convention. |
| `utm_source_platform` | Platform managing the traffic. | `Google Ads` | Supported by Google Analytics. |

Use IDs for reporting joins. URL-encode free-text values. An empty value or an
unresolved macro is missing data. If a restriction is undocumented, check the
linked source or a real click before relying on it.

## Sources

- [Google Analytics campaign URL parameters](https://support.google.com/analytics/answer/10917952)
