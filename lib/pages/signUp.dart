import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _errorMessage = '';

  // Firebase Auth ve Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kayıt işlemi
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = ''; // Hata mesajını sıfırla
      });
      try {
        // Firebase Authentication ile kullanıcı kaydını oluştur
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Firestore'a kullanıcı bilgilerini kaydet
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        // Kayıt başarılı olduğunda, kullanıcıyı anasayfaya yönlendir veya login sayfasına
        // Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt başarılı!')));
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Ad TextFormField
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              // E-mail TextFormField
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta girin';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                    return 'Geçersiz e-posta adresi';
                  }
                  return null;
                },
              ),
              // Telefon TextFormField
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefon Numarası'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numarası girin';
                  }
                  return null;
                },
              ),
              // Şifre TextFormField
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifre girin';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
              ),
              // Hata mesajı
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              // Kayıt ol butonu
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
