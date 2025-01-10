import 'package:flutter/material.dart';
import 'package:filmdeneme/services/UserService.dart'; // UserService'i dahil ettik
import 'package:filmdeneme/widgets/MovieCard.dart'; // MovieCard widget'ını dahil ettik
import 'package:filmdeneme/theme/app_theme.dart'; // App teması
import 'package:filmdeneme/pages/DetailsPage.dart';
import 'package:filmdeneme/pages/UserProfilePage.dart';
import 'package:filmdeneme/services/api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'Film'; // Varsayılan filtre
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  final UserService _userService = UserService(); // UserService'i kullanıyoruz

  // Arama işlemini tetikleyen metot
  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> results = [];
      if (_filter == 'Film') {
        results = await ApiService(apiKey: 'AIzaSyAZUdCH99178o1u6DyFH5yucWc5OjlNi1k').searchMovies(_searchQuery);
      } else if (_filter == 'Dizi') {
        results = await ApiService(apiKey: 'AIzaSyAZUdCH99178o1u6DyFH5yucWc5OjlNi1k').searchTVShows(_searchQuery);
      } else if (_filter == 'Kullanıcı') {
        results = await _userService.searchUsers(_searchQuery); // Kullanıcı aramasını yaptık
      }

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama sırasında bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arama'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Arama metni girişi
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Ara',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _searchResults = [];
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Filtre seçimi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Film', 'Dizi', 'Kullanıcı'].map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _filter = filter;
                        _searchResults = [];
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Arama sonuçları
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? const Center(child: Text('Sonuç bulunamadı'))
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];

                  // Burada, arama sonuçlarında 'uid' olduğunu kontrol edelim
                  print("Arama Sonucu: $result");

                  if (_filter == 'Kullanıcı') {
                    return ListTile(
                      title: Text(result['name'] ?? 'Name not available'), // Kullanıcı adı
                      onTap: () {
                        final userId = result['uid'];  // 'uid' burada alınıyor
                        print("Kullanıcı ID: $userId"); // Burada 'userId' değerini yazdırıyoruz

                        if (userId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(
                                userId: userId,  // Burada 'userId' parametresi gönderiliyor
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User ID not available')),
                          );
                        }
                      },
                    );
                  }
                  // Diğer filtreler için MovieCard ekleyebilirsiniz
                  return MovieCard(
                    title: result['title'],
                    posterPath: result['poster_path'],
                    overview: result['overview'] ?? 'No description available',
                    releaseDate: result['release_date'] ?? 'Unknown',
                    director: result['director'] ?? 'Unknown',
                    actors: result['cast'] != null
                        ? List<String>.from(result['cast'].map((actor) => actor['name']))
                        : [], // Actors listesi
                    isMovie: _filter == 'Film', // isMovie durumunu belirleyin
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(
                            movieId: result['id'], // Movie ID
                            title: result['title'], // Movie title
                            overview: result['overview'] ?? 'No description available', // Overview
                            posterPath: result['poster_path'], // Poster path
                            releaseDate: result['release_date'] ?? 'Unknown', // Release date
                            director: result['director'] ?? 'Unknown', // Director
                            actors: result['cast'] != null
                                ? List<String>.from(result['cast'].map((actor) => actor['name']))
                                : [], // Actors list
                            isMovie: _filter == 'Film', // isMovie flag
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _performSearch,
        child: const Icon(Icons.search),
      ),
    );
  }
}
