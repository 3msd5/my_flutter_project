import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  UserProfilePage({required this.userId});

  // Firestore'dan, belirtilen koleksiyonu çekmek için kullanılan metod
  Future<List<DocumentSnapshot>> _getMoviesFromCollection(String collectionName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName)
        .get();

    return querySnapshot.docs;  // Dokümanları döndürüyoruz
  }

  // Kullanıcı bilgilerini almak için kullanılan metod
  Future<DocumentSnapshot> _getUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return userDoc;  // Kullanıcı bilgilerini döndürüyoruz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _getUserData(),  // Kullanıcı bilgilerini alıyoruz
          _getMoviesFromCollection('favorites'),  // Favori filmleri alıyoruz
          _getMoviesFromCollection('watchlist'),  // İzleme listelerini alıyoruz
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('User not found'));
          }

          // Kullanıcı bilgilerini alıyoruz
          final userData = snapshot.data![0].data() as Map<String, dynamic>;
          final favoriteMovies = snapshot.data![1];
          final watchlistMovies = snapshot.data![2];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Bilgileri
                Text(
                  'Name and Surname: ${userData['name']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Email: ${userData['email']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Phone: ${userData['phone']}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),  // Kullanıcı bilgileri bitiminden sonra biraz boşluk

                // Favoriler kısmı
                Text(
                  'Favorites:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 250,  // Posterler için daha fazla alan
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteMovies.length,
                    itemBuilder: (context, index) {
                      // Favori film bilgilerini alıyoruz
                      final movie = favoriteMovies[index].data() as Map<String, dynamic>;
                      final posterPath = movie['posterPath'];  // Film poster URL'sini alıyoruz
                      final posterUrl = posterPath != null
                          ? 'https://image.tmdb.org/t/p/w500$posterPath'
                          : null;  // Poster URL'sini oluşturuyoruz

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Poster görüntüleme
                              posterUrl != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  posterUrl,
                                  height: 150,  // Poster yüksekliği
                                  width: 100,   // Poster genişliği
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Icon(Icons.image, size: 100),  // Poster yoksa yedek ikon göster

                              // Alt şerit
                              Container(
                                width: 100,
                                height: 40,  // Alt şerit yüksekliği
                                decoration: BoxDecoration(
                                  color: Colors.white24.withOpacity(0.7),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    movie['title'] ?? 'No title',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,  // Daha büyük font boyutu
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16),

                // İzleme Listesi kısmı
                Text(
                  'Watchlist:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 250,  // Posterler için daha fazla alan
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: watchlistMovies.length,
                    itemBuilder: (context, index) {
                      // İzleme listesi film bilgilerini alıyoruz
                      final movie = watchlistMovies[index].data() as Map<String, dynamic>;
                      final posterPath = movie['posterPath'];  // Film poster URL'sini alıyoruz
                      final posterUrl = posterPath != null
                          ? 'https://image.tmdb.org/t/p/w500$posterPath'
                          : null;  // Poster URL'sini oluşturuyoruz

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Poster görüntüleme
                              posterUrl != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  posterUrl,
                                  height: 150,  // Poster yüksekliği
                                  width: 100,   // Poster genişliği
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Icon(Icons.image, size: 100),  // Poster yoksa yedek ikon göster

                              // Alt şerit
                              Container(
                                width: 100,
                                height: 40,  // Alt şerit yüksekliği
                                decoration: BoxDecoration(
                                  color: Colors.white24.withOpacity(0.7),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    movie['title'] ?? 'No title',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,  // Daha büyük font boyutu
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
