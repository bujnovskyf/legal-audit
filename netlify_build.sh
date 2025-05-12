#!/usr/bin/env bash
set -e  # exit immediately on any error

# === Step 1: Clone Flutter SDK (stable branch) if missing ===
if [ -d "flutter" ]; then
  echo "✅ Flutter SDK already present"
else
  echo "🔄 Cloning Flutter SDK (stable)…"
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
fi

# Add flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# (Optional) Pre-download web artifacts
flutter precache --web

# === Step 2: Build the Flutter web app ===
echo "🚀 Building Flutter web (release)…"
cd apps/frontend

# fetch pub dependencies
flutter pub get --no-precompile

# build with your API_BASE_URL from Netlify env
flutter build web --release \
  --dart-define=API_BASE_URL=$API_BASE_URL

echo "Flutter web build complete at apps/frontend/build/web"