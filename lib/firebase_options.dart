// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZu9Ip1Gj9Pg3x_Lghvs_TIyNh78e_mrI',
    appId: '1:792547666707:android:865bcc3cf02de024a9c8e6',
    messagingSenderId: '792547666707',
    projectId: 'loaning-e3739',
    databaseURL: 'https://loaning-e3739.firebaseio.com',
    storageBucket: 'loaning-e3739.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCINDD_GVzjK9Q4-VBjNXSrsualke39sBA',
    appId: '1:792547666707:ios:143f9dd67c4114c7a9c8e6',
    messagingSenderId: '792547666707',
    projectId: 'loaning-e3739',
    databaseURL: 'https://loaning-e3739.firebaseio.com',
    storageBucket: 'loaning-e3739.appspot.com',
    androidClientId: '792547666707-1sfccp6dhu517cpqajsuq1nfo49o0l7p.apps.googleusercontent.com',
    iosClientId: '792547666707-7ntddiu6lcc4fo0nrjr85t5s971s6ovk.apps.googleusercontent.com',
    iosBundleId: 'com.campdavid.campdavid',
  );
}
