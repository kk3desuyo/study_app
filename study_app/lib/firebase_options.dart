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
    apiKey: 'AIzaSyBy9o8xqG1a7KWIPqVPBZsCGAiTrfe8dkk',
    appId: '1:1087316148781:web:6b407acad41f2401fc2ea4',
    messagingSenderId: '1087316148781',
    projectId: 'study-app-6a883',
    authDomain: 'study-app-6a883.firebaseapp.com',
    storageBucket: 'study-app-6a883.appspot.com',
    measurementId: 'G-QSC0ZNYH6F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDL_N_p24J-dbvVFcl3XpRaE6enDr7GGc8',
    appId: '1:1087316148781:android:c2bd40162c0068a8fc2ea4',
    messagingSenderId: '1087316148781',
    projectId: 'study-app-6a883',
    storageBucket: 'study-app-6a883.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBiUNZHF0GNNkCoKc7tcdtWUvJdTi5U-Pg',
    appId: '1:1087316148781:ios:581ebb7bde84544afc2ea4',
    messagingSenderId: '1087316148781',
    projectId: 'study-app-6a883',
    storageBucket: 'study-app-6a883.appspot.com',
    iosBundleId: 'studyApp20041002',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBiUNZHF0GNNkCoKc7tcdtWUvJdTi5U-Pg',
    appId: '1:1087316148781:ios:c1817bbdfc4d8537fc2ea4',
    messagingSenderId: '1087316148781',
    projectId: 'study-app-6a883',
    storageBucket: 'study-app-6a883.appspot.com',
    iosBundleId: 'com.example.studyApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBy9o8xqG1a7KWIPqVPBZsCGAiTrfe8dkk',
    appId: '1:1087316148781:web:8c20b035b73be81cfc2ea4',
    messagingSenderId: '1087316148781',
    projectId: 'study-app-6a883',
    authDomain: 'study-app-6a883.firebaseapp.com',
    storageBucket: 'study-app-6a883.appspot.com',
    measurementId: 'G-FNR0YVNP7Q',
  );
}
