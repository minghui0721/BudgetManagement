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
    apiKey: 'AIzaSyC6RLX_Q3fUTUs_5NK9BVpmA30Ib-jzwJo',
    appId: '1:197786741274:web:05e1106d9f86c35cacbfa3',
    messagingSenderId: '197786741274',
    projectId: 'wise-6b980',
    authDomain: 'wise-6b980.firebaseapp.com',
    storageBucket: 'wise-6b980.appspot.com',
    measurementId: 'G-B28NE8LEJM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbKMtEawoTQsY6yBt1AxCjpE4nDkUwO9Q',
    appId: '1:197786741274:android:765b11ee54e4c7b9acbfa3',
    messagingSenderId: '197786741274',
    projectId: 'wise-6b980',
    storageBucket: 'wise-6b980.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOVlITB6m8McLNKd2B8JIX0IrrVceaY9Y',
    appId: '1:197786741274:ios:31dee398ff7999d5acbfa3',
    messagingSenderId: '197786741274',
    projectId: 'wise-6b980',
    storageBucket: 'wise-6b980.appspot.com',
    iosBundleId: 'com.example.wise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOVlITB6m8McLNKd2B8JIX0IrrVceaY9Y',
    appId: '1:197786741274:ios:31dee398ff7999d5acbfa3',
    messagingSenderId: '197786741274',
    projectId: 'wise-6b980',
    storageBucket: 'wise-6b980.appspot.com',
    iosBundleId: 'com.example.wise',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC6RLX_Q3fUTUs_5NK9BVpmA30Ib-jzwJo',
    appId: '1:197786741274:web:75e46d3b5a98e124acbfa3',
    messagingSenderId: '197786741274',
    projectId: 'wise-6b980',
    authDomain: 'wise-6b980.firebaseapp.com',
    storageBucket: 'wise-6b980.appspot.com',
    measurementId: 'G-QGN2YDD5G4',
  );
}