# purvi_vogue

A new Flutter project.

## Backend Setup (Firebase + Cloudinary)

1) Firebase
- Install Firebase CLI and FlutterFire: `dart pub global activate flutterfire_cli`
- Login: `firebase login`
- Configure: `flutterfire configure` (select this project)
- Deploy rules: `firebase deploy --only firestore:rules`

2) Cloudinary
- Create account and an unsigned upload preset
- Set values in `lib/config/cloudinary_config.dart`

3) Run
- Fetch deps: `flutter pub get`
- Run: `flutter run`


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
