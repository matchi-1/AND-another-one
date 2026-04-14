# AND Another One

A Flutter game built around logic, competitive play, and Firebase-backed accounts and leaderboards.

## Overview

AND Another One is a multi-platform Flutter app with authentication, Firestore persistence, and score tracking. It supports:

- Username-based sign-in and registration
- Firestore-backed user profiles
- Leaderboards and score submission
- Gameplay flows for the included game modes and guides

The app initializes Firebase in `lib/main.dart` and uses the generated Firebase configuration in `lib/firebase_options.dart`.

## Tech Stack

- Flutter
- Dart 3.11+
- Firebase Authentication
- Cloud Firestore
- Android, Windows, and Web targets

## Prerequisites

Install the following before setting up the project:

- Git
- Flutter stable channel
- Dart SDK that matches the Flutter installation
- VS Code or Android Studio
- Android Studio with Android SDK, platform tools, and an emulator image
- JDK 17 for Android builds
- Visual Studio 2022 with Desktop development with C++ if you want Windows desktop builds

If you plan to build for iOS or macOS, you also need a Mac with Xcode.

## Project Setup

1. Clone the repository and open the project folder.
2. Verify Flutter is installed correctly:

	```bash
	flutter doctor -v
	```

3. Accept Android licenses if needed:

	```bash
	flutter doctor --android-licenses
	```

4. Fetch dependencies:

	```bash
	flutter pub get
	```

5. Confirm that Firebase is configured:
	- Android Firebase config is already included in `android/app/google-services.json`
	- Cross-platform Firebase options are already included in `lib/firebase_options.dart`
	- Authentication should have Email/Password enabled in the Firebase console
	- Firestore must be created for the project

## Run the App

Use the target that matches your device:

```bash
flutter devices
flutter run
```

Common target examples:

- Android emulator or phone: `flutter run`
- Windows desktop: `flutter run -d windows`
- Web in Chrome: `flutter run -d chrome`

## Build

```bash
flutter test
flutter build apk
flutter build web
flutter build windows
```

## Firebase Notes

The app uses a hidden-email strategy for username login. Usernames are stored in Firestore and mapped to Firebase Auth accounts behind the scenes.

Expected Firestore usage includes:

- `usernames`
- `users`
- leaderboard-related collections used by the game and leaderboard services

If you change Firebase projects, regenerate the platform config and replace the checked-in Firebase files accordingly.

## Assets

Image assets are declared in `pubspec.yaml` and live under `assets/images/`.

## Troubleshooting

- If the app fails at startup, verify Firebase initialization and confirm that `lib/firebase_options.dart` matches the active Firebase project.
- If Android builds fail, check that Java 17, the Android SDK, and Android Gradle tooling are installed.
- If Flutter cannot find a device, run `flutter devices` and start an emulator or connect a physical device.

## Contributing

Keep changes focused and consistent with the existing feature-based structure under `lib/`. If you add assets or Firebase features, update the configuration and documentation together.
