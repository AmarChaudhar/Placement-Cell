import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:placement/AdminData/admin_home.dart';

import 'package:placement/app_home.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApps());
  await Future.delayed(
    Duration(seconds: 8),
  );
  FlutterNativeSplash.remove();
}

class MyApps extends StatelessWidget {
  const MyApps({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (FirebaseAuth.instance.currentUser != null)
          ? (FirebaseAuth.instance.currentUser!.emailVerified)
              ? AfterVerify()
              : AppHome()
          : AfterVerify(),
    );
  }
}
