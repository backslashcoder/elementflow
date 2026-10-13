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

## Component mappers (your own widgets)

Teams rarely use stock Flutter widgets. Upload a **component mapper** (a JSON file) from the **Mapper** menu and ElementFlow generates code with *your* widgets, imports and theme instead of the defaults. Three samples ship with the app (Material 3, Cupertino, and a self-contained "Acme UI" design system), and the Mapper dialog has a format reference and a downloadable template.

```json
{
  "name": "My component library",
  "imports": ["package:my_ui/my_ui.dart"],
  "components": [
    { "selector": "button.primary", "widget": "MyButton",
      "args": { "label": "{{text}}", "onPressed": "() {}" } },
    { "selector": ".card", "widget": "MyCard", "children": "child",
      "args": { "child": "{{child}}" } }
  ]
}
```

- `selector` is a CSS selector; the most specific match wins (later rules win ties).
- `args` / `positional` are Dart expression templates using variables such as `{{text}}`, `{{placeholder}}`, `{{attr.NAME}}`, `{{checked}}`, `{{options}}`, `{{child}}`, `{{children}}` and computed CSS like `{{style.backgroundColor}}`.
- Optional: `imports`, `theme` (expression for `MaterialApp.theme`), `declarations` (Dart source for helper widgets, appended to the file) and per-rule `children` / `box`.
- **Generate it with AI:** the Mapper dialog has a ready-made prompt (**Copy AI prompt**). Give it to an assistant that can read your component library, save the JSON it returns and upload it.
- The mapper is validated on upload and every problem is listed. Your widgets cannot run inside ElementFlow, so the Flutter preview shows the standard equivalents; the generated Dart code and the report show where your widgets are used.

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
