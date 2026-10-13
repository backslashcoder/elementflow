# ElementFlow

**From HTML to Flutter. Seamlessly.**

ElementFlow is a browser-based tool that converts HTML and CSS into Flutter widgets. Paste or upload HTML, preview it, convert it, preview the real Flutter result, and export one self-contained Dart file. Everything runs locally in the browser: no backend, no accounts, no AI services.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

```bash
flutter analyze
flutter test
```

Requires Flutter 3.47.6 (the version pinned in `scripts/vercel_build.sh`). Generated code targets Flutter 3.27 or newer.

## Deploy to Vercel

Vercel's build image has no Flutter SDK, so `vercel.json` runs `scripts/vercel_build.sh`, which installs the pinned Flutter version, builds the web app with bundled CanvasKit, and serves `build/web`.

### Option A: Git integration (recommended)

1. Push this repository to GitHub, GitLab or Bitbucket.
2. In Vercel choose **Add New → Project** and import the repository.
3. Leave the settings as they are. `vercel.json` already sets the build command, output directory and headers (Framework Preset: *Other*).
4. Deploy. The first build takes a few minutes because Flutter is downloaded; to use another Flutter version set the `FLUTTER_VERSION` environment variable in the project settings.

### Option B: Vercel CLI, prebuilt locally

If you would rather build on your machine and upload only the result:

```bash
flutter build web --release --no-web-resources-cdn
cd build/web
vercel deploy --prod
```

(Run `vercel deploy` from `build/web` so the static files are uploaded as the site root. The repo-level `vercel.json` headers do not apply in this mode; copy `vercel.json` into `build/web` and remove the `buildCommand`, `installCommand` and `outputDirectory` entries if you want them.)

### What the deployment config does

- `vercel.json`: build command, output directory, security headers, and cache rules (`index.html`, service worker and bootstrap are never cached; `assets/`, `canvaskit/` and `icons/` are cached for a day).
- `.vercelignore`: keeps tests, caches and local tooling out of the upload.
- `web/index.html`, `web/manifest.json`: product title, description, social tags and a dark loading screen.

## Notes

- Sample pages load images from `picsum.photos`; those need internet access.
- Fonts (Inter, JetBrains Mono) are fetched from Google Fonts at runtime. If they cannot load, the UI falls back to default fonts.
- The HTML preview runs user HTML in a sandboxed iframe with scripts disabled.
