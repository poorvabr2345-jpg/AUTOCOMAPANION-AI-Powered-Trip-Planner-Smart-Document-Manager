# ==========================================
# BUILD SCRIPTS FOR AUTOCOMPANION (PowerShell)
# ==========================================

# WEB BUILD
# ---------

# Build web version (HTML renderer)
flutter build web --release --web-renderer html

# Build web version (CanvasKit renderer)
flutter build web --release --web-renderer canvaskit

# Build web with custom base href
flutter build web --release --base-href "/autocompanion/"

# ANDROID BUILD
# -------------

# Build App Bundle (AAB) for Play Store - RECOMMENDED
flutter build appbundle --release

# Build APK (single file)
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --split-per-abi --release

# CLEAN & REBUILD
# ---------------

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Clean and rebuild web
flutter clean; flutter pub get; flutter build web --release

# Clean and rebuild Android
flutter clean; flutter pub get; flutter build appbundle --release

# DEVELOPMENT
# -----------

# Run on Chrome
flutter run -d chrome

# Run on Android
flutter run

# Run in release mode
flutter run --release

# DEPLOYMENT
# ----------

# Web - Firebase Hosting
flutter build web --release; firebase deploy --only hosting

# Web - Netlify
flutter build web --release; netlify deploy --prod --dir=build/web

# Android - Build and open folder
flutter build appbundle --release; explorer build\app\outputs\bundle\release

# TESTING & ANALYSIS
# ------------------

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Check Flutter setup
flutter doctor -v

# Check for outdated packages
flutter pub outdated
