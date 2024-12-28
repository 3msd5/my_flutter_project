import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart'; // Giriş başarılıysa gidilecek sayfa
import 'signUp.dart'; // Kayıt olma sayfasına yönlendirme
import 'ResetPasswordPage.dart'; // Şifre sıfırlama sayfasına yönlendirme

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  // Form doğrulama
  bool _validateInputs() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Giriş yapılmadan önce inputları doğrula
    if (!_validateInputs()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Firebase Authentication ile giriş işlemi
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Giriş işlemi başarılıysa, HomePage'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      // Başarılı girişten sonra formu temizle
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      // Firebase Auth hatası yönetimi
      String errorMsg = '';
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'User not found';
          break;
        case 'wrong-password':
          errorMsg = 'Wrong password';
          break;
        case 'invalid-email':
          errorMsg = 'Invalid email address';
          break;
        default:
          errorMsg = e.message ?? 'An error occurred';
      }

      setState(() {
        _errorMessage = errorMsg;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to MovieScout App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo ekleme kısmı
            Center(
              child: Image.asset(
                'assets/images/moviescoutlogo.png',  // Logonun bulunduğu dosya yolu
                height: 200,  // İhtiyaca göre boyutlandırabilirsiniz
                width: 200,   // İhtiyaca göre boyutlandırabilirsiniz
              ),
            ),
            SizedBox(height: 32), // Logodan form arasına boşluk eklemek için
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // E-posta input
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Şifre input
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Giriş yap butonu
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _login, // Giriş yap butonuna tıklandığında _login() fonksiyonu çalışacak
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Arka plan rengi (primary)
                      onPrimary: Colors.white, // Buton metninin rengi (onPrimary)
                      padding: EdgeInsets.symmetric(vertical: 16), // Butonun içindeki dikey boşluk
                    ),
                    child: Text('Log In'),
                  ),

                  // Kayıt ol butonu
                  TextButton(
                    onPressed: () {
                      // Kayıt ol sayfasına yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text("Don't have an account? Sign up"),
                  ),
                  // Şifrenizi unuttunuz butonu
                  TextButton(
                    onPressed: () {
                      // Şifre sıfırlama sayfasına yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                      );
                    },
                    child: Text("Forgot your password?"),
                  ),
                  // Hata mesajı
                  if (_errorMessage.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
