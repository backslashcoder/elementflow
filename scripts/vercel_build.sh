#!/usr/bin/env bash
# Builds ElementFlow for Vercel.
#
# Vercel's build image does not include Flutter, so this script installs the
# pinned Flutter SDK and runs `flutter build web`. The output is written to
# build/web, which vercel.json serves as the site.
set -euo pipefail

# Keep this in sync with the Flutter version the app was developed with.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.6}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter-sdk}"

# Flutter refuses to run as root / in "unsafe" git directories on CI.
git config --global --add safe.directory '*'
export FLUTTER_SUPPRESS_ANALYTICS=true
export CI=true

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION ..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

flutter --version
flutter config --no-analytics --enable-web >/dev/null
flutter precache --web
flutter pub get

# --no-web-resources-cdn bundles CanvasKit with the site instead of fetching
# it from gstatic.com, so the deployment has no runtime CDN dependency.
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run

echo "Build finished: $(du -sh build/web | cut -f1) in build/web"
