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
    apiKey: 'AIzaSyBjpe2sJQKYwyMxshu_8nB610VrjvN0kjE',
    appId: '1:311510262997:web:c99164406c7f1e3d57ee5c',
    messagingSenderId: '311510262997',
    projectId: 'newchatapp-92b7c',
    authDomain: 'newchatapp-92b7c.firebaseapp.com',
    storageBucket: 'newchatapp-92b7c.appspot.com',
    measurementId: 'G-9WN33HPHPZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCusLwWCF64qYaQ6XRfWD9oHni2YPcOVWo',
    appId: '1:311510262997:android:684c50209549d99d57ee5c',
    messagingSenderId: '311510262997',
    projectId: 'newchatapp-92b7c',
    storageBucket: 'newchatapp-92b7c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGuCqp2pMnmGzPrA0qiga2tmKPbJhcn1I',
    appId: '1:311510262997:ios:0ec00de5e56f130457ee5c',
    messagingSenderId: '311510262997',
    projectId: 'newchatapp-92b7c',
    storageBucket: 'newchatapp-92b7c.appspot.com',
    iosBundleId: 'com.example.newChatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGuCqp2pMnmGzPrA0qiga2tmKPbJhcn1I',
    appId: '1:311510262997:ios:0ec00de5e56f130457ee5c',
    messagingSenderId: '311510262997',
    projectId: 'newchatapp-92b7c',
    storageBucket: 'newchatapp-92b7c.appspot.com',
    iosBundleId: 'com.example.newChatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBjpe2sJQKYwyMxshu_8nB610VrjvN0kjE',
    appId: '1:311510262997:web:c12801ef8d53b2ba57ee5c',
    messagingSenderId: '311510262997',
    projectId: 'newchatapp-92b7c',
    authDomain: 'newchatapp-92b7c.firebaseapp.com',
    storageBucket: 'newchatapp-92b7c.appspot.com',
    measurementId: 'G-61Y7BVFFBT',
  );
}
