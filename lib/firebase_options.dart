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
    apiKey: 'AIzaSyB9hL62zlmjbdjFKs4OQbyyqqTKJuyu3uo',
    appId: '1:371754379023:web:3a5a756cc98c9b67c6c07a',
    messagingSenderId: '371754379023',
    projectId: 'community-buildings56119',
    authDomain: 'community-buildings56119.firebaseapp.com',
    storageBucket: 'community-buildings56119.firebasestorage.app',
    measurementId: 'G-207E4CLY37',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDa5CuLKVaHfDHJvTb472UQcFoNCQcGYA',
    appId: '1:371754379023:android:74270f613963df3ec6c07a',
    messagingSenderId: '371754379023',
    projectId: 'community-buildings56119',
    storageBucket: 'community-buildings56119.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXXPH8CaBHyXNqDF24gUCPklDrRi0fw_0',
    appId: '1:371754379023:ios:1815986feb74b510c6c07a',
    messagingSenderId: '371754379023',
    projectId: 'community-buildings56119',
    storageBucket: 'community-buildings56119.firebasestorage.app',
    iosBundleId: 'com.example.startnest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBXXPH8CaBHyXNqDF24gUCPklDrRi0fw_0',
    appId: '1:371754379023:ios:1815986feb74b510c6c07a',
    messagingSenderId: '371754379023',
    projectId: 'community-buildings56119',
    storageBucket: 'community-buildings56119.firebasestorage.app',
    iosBundleId: 'com.example.startnest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB9hL62zlmjbdjFKs4OQbyyqqTKJuyu3uo',
    appId: '1:371754379023:web:1e36756d0985b2f1c6c07a',
    messagingSenderId: '371754379023',
    projectId: 'community-buildings56119',
    authDomain: 'community-buildings56119.firebaseapp.com',
    storageBucket: 'community-buildings56119.firebasestorage.app',
    measurementId: 'G-WC7GB5QWQ1',
  );
}
