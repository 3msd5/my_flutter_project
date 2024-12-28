import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
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
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Kullanıcı Adı: John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Email: johndoe@example.com'),
            SizedBox(height: 8),
            Text('Telefon: +90 123 456 7890'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Çıkış yapma işlemi yapılabilir
                Navigator.pop(context); // Profil sayfasından çıkış yap
              },
              child: Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
