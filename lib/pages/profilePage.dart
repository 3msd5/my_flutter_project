import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String _userId = '';

  // Kullanıcı bilgilerini Firestore'dan al
  void _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        _nameController.text = userDoc['name'] ?? '';
        _phoneController.text = userDoc['phone'] ?? '';
      }
    }
  }

  // Kullanıcı bilgilerini güncelle
  void _updateUserData() async {
    try {
      await _firestore.collection('users').doc(_userId).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
      });

      // Başarılı bir güncelleme sonrası kullanıcıya mesaj ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil başarıyla güncellendi!')),
      );
    } catch (e) {
      print("Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil güncellenirken bir hata oluştu.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilim'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil fotoğrafı
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 16),

            // Kullanıcı adı alanı
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),

            // Kullanıcı telefon numarası alanı
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Telefon Numarası',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Güncelle butonu
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
