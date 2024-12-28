import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart'; // ApiService sınıfını import edin

class DetailsPage extends StatefulWidget {
  final int movieId;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final String director;
  final List<String> actors;
  final bool isMovie;

  const DetailsPage({
    Key? key,
    required this.movieId,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.director,
    required this.actors,
    required this.isMovie,
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>> movieData;

  @override
  void initState() {
    super.initState();
    // API çağrısını başlat
    movieData = ApiService().fetchMovieDetailsWithCredits(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: movieData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // Yükleniyor ikonu
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));  // Hata mesajı
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Film veya dizi posteri
                  data['poster_path'] != null
                      ? Image.network(
                    'https://image.tmdb.org/t/p/w500${data['poster_path']}',
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  ),

                  // Yayınlanma tarihi
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Release Date: ${data['release_date'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                  // Film/Dizi açıklaması
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      data['overview'] ?? 'Description not available.',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ),

                  // Yönetmen
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Director: ${data['director'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Oyuncular
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Actors:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        if (data['actors'] != null && data['actors'].isNotEmpty)
                          ...data['actors'].map((actor) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              actor,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                        else
                          const Text(
                            'Unknown',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),

                  // Durum (Status)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Status: ${data['status'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Orijinal Dil
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Original Language: ${data['original_language']?.toUpperCase() ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // Kullanıcı Puanı (User Score)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'User Score: ${data['user_score'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // Film Süresi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Süre: ${data['runtime'] != null ? '${data['runtime']} dakika' : 'Unknown'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // Türler
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Türler:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        if (data['genres'] != null && data['genres'].isNotEmpty)
                          ...data['genres'].map((genre) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              genre['name'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                        else
                          const Text(
                            'Unknown',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
