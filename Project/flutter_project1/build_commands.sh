#!/bin/bash
# Build Scripts for AutoCompanion

# ==========================================
# WEB BUILD SCRIPTS
# ==========================================

# Build web version (HTML renderer - smaller size)
flutter build web --release --web-renderer html

# Build web version (CanvasKit renderer - better performance)
flutter build web --release --web-renderer canvaskit

# Build web version with custom base href (for subdirectory hosting)
flutter build web --release --base-href "/autocompanion/"

# Build web with source maps (for debugging production issues)
flutter build web --release --source-maps

# ==========================================
# ANDROID BUILD SCRIPTS
# ==========================================

# Build App Bundle (AAB) - RECOMMENDED for Play Store
flutter build appbundle --release

# Build APK (single file for all architectures)
flutter build apk --release

# Build split APKs (smaller downloads, one per architecture)
flutter build apk --split-per-abi --release

# Build APK for specific architecture
flutter build apk --release --target-platform android-arm64

# Build in profile mode (for performance testing)
flutter build apk --profile

# ==========================================
# iOS BUILD SCRIPTS (if you have Mac)
# ==========================================

# Build iOS app
flutter build ios --release

# Build iOS IPA for App Store
flutter build ipa --release

# ==========================================
# DEVELOPMENT BUILD SCRIPTS
# ==========================================

# Run on Chrome
flutter run -d chrome

# Run on Android device
flutter run -d android

# Run on iOS device
flutter run -d ios

# Run in release mode
flutter run --release

# Run with hot reload on web
flutter run -d chrome --hot

# ==========================================
# CLEAN & REBUILD
# ==========================================

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean and rebuild web
flutter clean && flutter pub get && flutter build web --release

# Clean and rebuild Android
flutter clean && flutter pub get && flutter build appbundle --release

# ==========================================
# TESTING SCRIPTS
# ==========================================

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format all Dart files
dart format .

# Check for outdated packages
flutter pub outdated

# ==========================================
# PRODUCTION DEPLOYMENT
# ==========================================

# Web - Firebase Hosting
flutter build web --release && firebase deploy --only hosting

# Web - Netlify
flutter build web --release && netlify deploy --prod --dir=build/web

# Android - Build and open output folder
flutter build appbundle --release && explorer build\app\outputs\bundle\release

# ==========================================
# VERSION MANAGEMENT
# ==========================================

# Update version in pubspec.yaml before each release!
# Format: major.minor.patch+buildNumber
# Example: 1.2.3+15
# - Increment build number (+1) for every release
# - Increment patch (0.0.+1) for bug fixes
# - Increment minor (0.+1.0) for new features
# - Increment major (+1.0.0) for breaking changes

# ==========================================
# USEFUL COMMANDS
# ==========================================

# Check Flutter doctor
flutter doctor -v

# List all connected devices
flutter devices

# Install app on connected device
flutter install

# Get app logs
flutter logs

# Take screenshot from running app
flutter screenshot

# Check app size
flutter build apk --analyze-size

# Profile app performance
flutter run --profile --trace-startup
