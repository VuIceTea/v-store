// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBoDsJiku0JVKAINX-Bs7KkZl0dqkZoFgc',
    appId: '1:941307482335:web:795d6a6a2144f3b495596a',
    messagingSenderId: '941307482335',
    projectId: 'v-store-e2e87',
    authDomain: 'v-store-e2e87.firebaseapp.com',
    storageBucket: 'v-store-e2e87.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRVYg6UdMTD85-rr8kRY42FRZ_fdPrStE',
    appId: '1:941307482335:android:44e929990ac0455395596a',
    messagingSenderId: '941307482335',
    projectId: 'v-store-e2e87',
    storageBucket: 'v-store-e2e87.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUZ0W3daCcb8JPyiRuJQYgc8vAiVGHqH8',
    appId: '1:941307482335:ios:941cec733335bfb195596a',
    messagingSenderId: '941307482335',
    projectId: 'v-store-e2e87',
    storageBucket: 'v-store-e2e87.firebasestorage.app',
    iosBundleId: 'com.example.vStore',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDUZ0W3daCcb8JPyiRuJQYgc8vAiVGHqH8',
    appId: '1:941307482335:ios:941cec733335bfb195596a',
    messagingSenderId: '941307482335',
    projectId: 'v-store-e2e87',
    storageBucket: 'v-store-e2e87.firebasestorage.app',
    iosBundleId: 'com.example.vStore',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBoDsJiku0JVKAINX-Bs7KkZl0dqkZoFgc',
    appId: '1:941307482335:web:96d1e009f69a2d7395596a',
    messagingSenderId: '941307482335',
    projectId: 'v-store-e2e87',
    authDomain: 'v-store-e2e87.firebaseapp.com',
    storageBucket: 'v-store-e2e87.firebasestorage.app',
  );
}
