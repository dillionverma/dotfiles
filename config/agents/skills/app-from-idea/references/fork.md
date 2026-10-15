# Fork Arnold for a new app

Every new app starts as a fork of [productstudioinc/arnold](https://github.com/productstudioinc/arnold). The fork brings Arnold's working stack, its `app` CLI, the `verify` and `acceptance` checks, the gates, and vendor adapters with `off`, `fake` and `live` modes. Wallpapery (`~/src/personal/wallpapery`) was the first app made this way. Clone to running app took under 15 minutes, most of it the first native build.

## 1. Clone and cut the tie to Arnold

```sh
gh repo clone productstudioinc/arnold ~/src/personal/<slug>
cd ~/src/personal/<slug>
git remote set-url --push origin no-push
```

Keep the remote named `origin`: `pnpm check` and the pre-push `verify check` diff against `origin/main`. Pulling Arnold fixes still works, but nothing can be pushed to it. Once the user chooses where the app lives, point `origin` at the app's own repo.

## 2. Toolchain

| Tool | Notes |
|---|---|
| pnpm 12.8.1 | The repo requires this exact version. Don't change the global pnpm: `npm i --prefix ~/.cache/pnpm-12.8.1 pnpm@12.8.1`, then put `~/.cache/pnpm-12.8.1/node_modules/.bin` first on `PATH` |
| Node 24.21.0 | pnpm downloads it for scripts |
| Xcode + iOS 26.5 simulator runtime | For iOS |
| CocoaPods | For iOS. Install it through nixpkgs in the dotfiles (`home.nix`). A `brew install` is removed again by nix-darwin's Homebrew cleanup |
| Android SDK + JDK 17 | For Android |
| actionlint | `pnpm check` validates GitHub workflows with it |
| UTF-8 locale | `LANG=en_US.UTF-8`. CocoaPods aborts without one |

## 3. Set up and rename

```sh
pnpm setup
node scripts/rename.mjs <slug> <bundle-id> --name "<Name>"
pnpm install --frozen-lockfile
pnpm app doctor --json --native
```

Upstream Arnold's `scripts/rename.mjs` still has the old template names (`App Template`) hard-coded. If it reports only about 2 files changed, take Wallpapery's version of `scripts/rename.mjs` and `scripts/rename.test.mjs`, which read the current names from `apps/native/app.config.ts`, and run it again.

## 4. Run it

```sh
pnpm app dev --wait
pnpm app sim
pnpm app sim --platform android
```

| First-run failure | Fix |
|---|---|
| `CocoaPods is not installed` | Install CocoaPods (see the toolchain table) |
| `could not find compatible versions for pod …` | `pod repo update`, then retry |
| CocoaPods complains about encoding | Set `LANG=en_US.UTF-8`. Wallpapery's CLI sets it for Stim |
| A change to native config doesn't take effect | Stim's build cache skipped prebuild. Delete `apps/native/ios` and run `pnpm app sim --rebuild` |

## 5. Remove Arnold's own features

Arnold is an AI health coach. Remove everything that only serves that:
- the coach: `packages/agent`, the coach Worker and Durable Object, its screens, CLI command and verify recipes
- health data (HealthKit, Health Connect), food and nutrition (the USDA table and import), regimen, meal photos, documents, voice
- `apps/studio` (the prompt studio), and `apps/web` (the marketing site) unless the new app needs a website
- vendors only those features use, such as Anthropic, OpenRouter, Context.dev and USDA FoodData Central

Keep auth, billing, the onboarding shell, settings, growth (Singular, PostHog, Sentry), the `app` CLI, `verify`, `acceptance` and every gate.

A removed feature is still named in config and checks. Update all of these:
- dependency-cruiser rules
- `tooling/checks` (structure, vendors, acceptance)
- `.fallowrc.jsonc`
- the vendor table and `docs/setup/`
- `.agents/skills/verify/features`
- `AGENTS.md` and `docs/`

Keep `pnpm check` passing after each removal, not only at the end.

## 6. Match the skill's defaults

- **Paywall:** replace Superwall with RevenueCat Paywalls (`react-native-purchases-ui`). RevenueCat stays the only purchase and entitlement owner. Update the kernel's paywall port, the fakes, the verify recipes, the vendor rows and the setup docs.
- **ATT:** Arnold prompts at Settings → Upgrade. Move the prompt to first launch, before Singular starts.
- **Pricing and web checkout:** the defaults in `SKILL.md`.
