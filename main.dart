import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'phone_auth_screen.dart'; // تأكد أن اسم ملف شاشة الهاتف مطابق لديك

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SiyantiApp());
}

class SiyantiApp extends StatelessWidget {
  const SiyantiApp({super.key});

  @root
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
