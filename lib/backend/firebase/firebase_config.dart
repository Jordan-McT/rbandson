import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCGKWbbtHWb6IVZb2Ip3FukW-IXP1sRbzI",
            authDomain: "itdma-text-recognition-app.firebaseapp.com",
            projectId: "itdma-text-recognition-app",
            storageBucket: "itdma-text-recognition-app.appspot.com",
            messagingSenderId: "320054313505",
            appId: "1:320054313505:web:b38250c9b4c8acbdacd960",
            measurementId: "G-H6J2QM958X"));
  } else {
    await Firebase.initializeApp();
  }
}
