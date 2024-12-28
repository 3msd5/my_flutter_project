import 'package:filmdeneme/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/loginPage.dart';
import 'pages/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Oturum durumu değişikliklerini dinliyoruz
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Firebase başlatılıyor, bekle
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            // Hata varsa ekrana yazdır
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          // snapshot.data == null ise kullanıcı giriş yapmamış demek
          return snapshot.data == null ? LoginPage() : HomePage();

        },
      ),
    );
  }
}
