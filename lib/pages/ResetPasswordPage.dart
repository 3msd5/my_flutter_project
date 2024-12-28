import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  String _errorMessage = '';

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = '';
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      setState(() {
        _message = 'Password reset email sent! Check your inbox.';
      });
    } on FirebaseAuthException catch (e) {
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
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            // Şifre sıfırlama butonu
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Send Reset Link'),
            ),
            // Mesajlar
            if (_message.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                _message,
                style: TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
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
    );
  }
}
