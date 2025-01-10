import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  UserProfilePage({required this.userId});

  Future<DocumentSnapshot> _getUserData() async {
    return await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Fotoğrafı
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user['photoURL'] != null
                        ? NetworkImage(user['photoURL'])
                        : null,
                    child: user['photoURL'] == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 16),

                // Ad Soyad
                Text(
                  'Name: ${user['name']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Favori Listesi
                Text(
                  'Favorites:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...List<Widget>.from(
                  (user['favorites'] as List<dynamic>?)
                      ?.map((item) => Text('- $item')) ??
                      [],
                ),
                SizedBox(height: 16),

                // İzleme Listesi
                Text(
                  'Watchlist:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...List<Widget>.from(
                  (user['watchlist'] as List<dynamic>?)
                      ?.map((item) => Text('- $item')) ??
                      [],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
