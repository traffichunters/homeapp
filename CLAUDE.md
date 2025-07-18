# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HomeApp is a Flutter iOS application for home management and smart home control. The app features a splash screen and home screen with a clean, modern design using Material Design 3.

## Technology Stack

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **iOS**: Primary target platform
- **Material Design 3**: UI design system

## Project Structure

```
lib/
├── main.dart              # App entry point and main widget
└── screens/
    ├── splash_screen.dart # Initial splash screen with HomeApp branding
    └── home_screen.dart   # Main home screen with feature cards
ios/                       # iOS-specific configuration
android/                   # Android configuration (not actively used)
```

## Common Commands

### Development
```bash
# Get dependencies
flutter pub get

# Run on iOS simulator
flutter run

# Run on connected iOS device
flutter run --release

# Build iOS app
flutter build ios

# Clean build files
flutter clean
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

## iOS Configuration

- Bundle identifier: `com.homeapp.homeapp`
- Display name: "HomeApp"
- Supports portrait and landscape orientations
- Minimum iOS version: Defined by Flutter SDK defaults

## Architecture Notes

- **Main App**: `HomeApp` widget serves as the root MaterialApp
- **Navigation**: Simple navigation from splash screen to home screen using Navigator.pushReplacement
- **Theming**: Custom blue theme based on Material Design 3 with Color(0xFF2196F3) as seed color
- **State Management**: Uses basic StatefulWidget for splash screen timing, StatelessWidget for home screen
- **UI Components**: Custom feature cards for home automation categories (Lights, Climate, Security)

## Development Workflow
- Always do a git push after finishing with Todo list item 