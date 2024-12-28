import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart'; // Giriş sayfasına yönlendirme

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  // Form doğrulama
  bool _validateInputs() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _signUp() async {
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
      // Firebase Authentication ile kullanıcı kaydı
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Kayıt işlemi başarılıysa, giriş sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      // Başarılı kayıttan sonra formu temizle
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      // Firebase Auth hatası yönetimi
      setState(() {
        _errorMessage = e.message ?? 'An error occurred';
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
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Görseli ekleyin
              Center(
                child: Image.asset(
                  'assets/images/moviescoutlogo.png', // Görselin yolu
                  height: 150, // Yükseklik isteğe göre ayarlanabilir
                  width: 150,  // Genişlik isteğe göre ayarlanabilir
                ),
              ),
              SizedBox(height: 16),
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
              // Kayıt ol butonu
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _signUp, // Kayıt ol butonuna tıklandığında _signUp() fonksiyonu çalışacak
                child: Text('Sign Up'),
              ),
              // Zaten hesabınız var mı? linki
              TextButton(
                onPressed: () {
                  // Giriş sayfasına yönlendirme
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text("Already have an account? Log in"),
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
      ),
    );
  }
}
