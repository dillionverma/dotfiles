# Google Play

Google Play links identify the app and can carry campaign data. Store listing
UTMs describe visits in Play Console. The encoded install referrer is a
separate payload that the installed app can retrieve.

## Parameters

| Parameter / macro | Meaning | Example value | Notes |
|---|---|---|---|
| `id` | App package name. | `com.example.app` | Required in `/store/apps/details` links. |
| `referrer` | Encoded referral data passed through installation. | `utm_source%3Dnewsletter%26utm_campaign%3Dsummer_launch` | Encode the complete nested query string as one value. |
| `utm_source` | Source of a store listing visit. | `newsletter` | Play Console shows this dimension with the Ads and referrals traffic filter. |
| `utm_campaign` | Campaign for a store listing visit. | `summer_launch` | Top-level parameter used in Play Console acquisition reports. |
| `listing` | Custom store listing URL token. | `summer_launch` | Unique token configured in Play Console. Lowercase letters, digits, `.`, `-`, `_`, and `~`. |

## Automatically added parameters

The linked Google Play sources do not define a universal store-link click ID.
Ad-platform click IDs and campaign macros belong to the upstream ad link.

## Notes

- A top-level `utm_source` and a `utm_source` inside `referrer` serve different
  consumers. Include the data each consumer needs.
- Shared UTM definitions are in [the skill](../SKILL.md#shared-utm-parameters).
  Google Play does not replace ad-platform macros.
- The Install Referrer API exposes referral content and click/install
  timestamps. A store listing visit is not proof of an app open.
- Google's Play Games on PC guide limits the encoded referrer to 512
  characters. That limit is documented for that flow.

## Sources

- [Linking to Google Play](https://developer.android.com/distribute/marketing-tools/linking-to-google-play)
- [Install Referrer API](https://developer.android.com/google/play/installreferrer)
- [Encoded referrer example](https://developer.android.com/games/playgames/user-acquisition)
- [Play Console acquisition dimensions](https://support.google.com/googleplay/android-developer/answer/9859173)
- [Custom store listing URLs](https://support.google.com/googleplay/android-developer/answer/9867158)
