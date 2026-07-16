// File generated manually from Firebase Console (project: trilha-biblia).
// Prefer regenerating with: flutterfire configure
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase Options for web not configured. '
        'Run flutterfire configure to add web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase Options for iOS not configured yet. '
          'Add an iOS app in the Firebase Console and run flutterfire configure, '
          'or download GoogleService-Info.plist into ios/Runner/.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase Options for macOS not configured yet. '
          'Run flutterfire configure to add macOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQyVZtXwtFLDXXY6hOI_lVFyELXYsvhhQ',
    appId: '1:397918013314:android:f10ffe7412ec73d952f19b',
    messagingSenderId: '397918013314',
    projectId: 'trilha-biblia',
    storageBucket: 'trilha-biblia.firebasestorage.app',
  );

  /// OAuth Web Client ID (type 3) — necessário para Google Sign-In + Firebase.
  /// Vem do google-services.json → oauth_client com client_type: 3.
  static const String googleWebClientId =
      '397918013314-qa8f7ccne3125e3m0p577vccu1fakc16.apps.googleusercontent.com';
}
