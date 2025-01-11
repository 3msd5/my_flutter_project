import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/HomePage.dart';
import 'pages/loginPage.dart';
import 'pages/signUp.dart';
import 'pages/profilePage.dart';
import 'pages/SearchPage.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieScout',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => _handleAuth(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        '/search': (context) => SearchPage(),
      },
      initialRoute: '/',
    );
  }

  Widget _handleAuth() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return HomePage();
        }

        return LoginPage();
      },
    );
  }
}
