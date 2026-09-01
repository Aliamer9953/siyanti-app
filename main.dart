import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'phone_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SiyantiApp());
}

class SiyantiApp extends StatelessWidget {
  const SiyantiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صيانتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const PhoneAuthScreen(),
    );
  }
}
