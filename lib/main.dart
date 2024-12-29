import 'package:filmdeneme/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/pages/loginPage.dart';
import 'package:filmdeneme/pages/HomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieScout',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentColor,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppTheme.textColor),
                ),
              ),
            );
          }

          // Default to LoginPage unless user is already logged in
          return LoginPage();
        },
      ),
    );
  }
}
