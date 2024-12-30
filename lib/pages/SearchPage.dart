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
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _isMovie = true;
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Debounce search to prevent too many API calls
  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
        _error = null;
      });
      return;
    }

    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
        _isLoading = true;
        _error = null;
      });

      try {
        final results = _isMovie
            ? await _apiService.searchMovies(query)
            : await _apiService.searchTVShows(query);

        if (mounted) {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(results);
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = 'Failed to perform search. Please try again.';
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _navigateToDetails(Map<String, dynamic> item) async {
    try {
      // Pre-fetch details to ensure data is ready
      final details = _isMovie
          ? await _apiService.fetchMovieDetailsWithCredits(item['id'], isMovie: true)
          : await _apiService.fetchMovieDetailsWithCredits(item['id'], isMovie: false);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsPage(
            movieId: item['id'],
            title: _isMovie
                ? (details['title'] ?? 'Unknown')
                : (details['name'] ?? 'Unknown'),
            overview: details['overview'] ?? '',
            posterPath: details['poster_path'] ?? '',
            releaseDate: _isMovie
                ? (details['release_date'] ?? 'Unknown')
                : (details['first_air_date'] ?? 'Unknown'),
            director: details['director'] ?? 'Unknown',
            actors: List<String>.from(details['cast']?.map((actor) => actor['name']) ?? []),
            isMovie: _isMovie,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load details. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentColor,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearchChanged,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.search : Icons.movie_filter,
              size: 64,
              color: AppTheme.secondaryTextColor,
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Search for ${_isMovie ? 'Movies' : 'TV Shows'}'
                  : 'No results found',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              ? (item['title'] ?? 'Unknown')
              : (item['name'] ?? 'Unknown'),
          posterPath: item['poster_path'] ?? '',
          voteAverage: (item['vote_average'] ?? 0.0).toDouble(),
          onTap: () => _navigateToDetails(item),
        );
      },
    );
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
                  _searchQuery = '';
                  _error = null;
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMovie ? Icons.movie : Icons.tv,
              color: AppTheme.accentColor,
            ),
            onPressed: () {
              setState(() {
                _isMovie = !_isMovie;
                if (_searchQuery.isNotEmpty) {
                  _onSearchChanged();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchResults.isNotEmpty)
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
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}
