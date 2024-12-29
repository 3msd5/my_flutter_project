import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/widgets/movie_card.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List _searchResults = [];
  bool _isLoading = false;
  bool _isMovie = true; // Toggle between movies and TV shows
  String _searchQuery = '';

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final results = _isMovie
          ? await _apiService.searchMovies(query)
          : await _apiService.searchTVShows(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error performing search: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppTheme.textColor),
          decoration: InputDecoration(
            hintText: 'Search ${_isMovie ? 'Movies' : 'TV Shows'}...',
            hintStyle: const TextStyle(color: AppTheme.secondaryTextColor),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.secondaryTextColor),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                });
              },
            ),
          ),
          onSubmitted: _performSearch,
        ),
        actions: [
          // Toggle between Movies and TV Shows
          IconButton(
            icon: Icon(
              _isMovie ? Icons.movie : Icons.tv,
              color: AppTheme.accentColor,
            ),
            onPressed: () {
              setState(() {
                _isMovie = !_isMovie;
                if (_searchQuery.isNotEmpty) {
                  _performSearch(_searchQuery);
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Type Indicator
          if (_searchResults.isNotEmpty || _isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Showing ${_isMovie ? 'Movies' : 'TV Shows'} results for: $_searchQuery',
                style: const TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentColor,
                    ),
                  )
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty ? Icons.search : Icons.movie_filter,
                              size: 64,
                              color: AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Search for ${_isMovie ? 'Movies' : 'TV Shows'}'
                                  : 'No results found',
                              style: const TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return MovieCard(
                            title: _isMovie
                                ? item['title'] ?? 'Unknown'
                                : item['name'] ?? 'Unknown',
                            posterPath: item['poster_path'] ?? '',
                            voteAverage:
                                (item['vote_average'] ?? 0.0).toDouble(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    movieId: item['id'],
                                    title: _isMovie
                                        ? item['title'] ?? 'Unknown'
                                        : item['name'] ?? 'Unknown',
                                    overview: item['overview'] ?? '',
                                    posterPath: item['poster_path'] ?? '',
                                    releaseDate: _isMovie
                                        ? item['release_date'] ?? 'Unknown'
                                        : item['first_air_date'] ?? 'Unknown',
                                    director: 'Loading...',
                                    actors: const [],
                                    isMovie: _isMovie,
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
    );
  }
}
