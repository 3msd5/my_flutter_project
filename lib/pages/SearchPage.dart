import 'package:flutter/material.dart';
import 'package:filmdeneme/services/UserService.dart';
import 'package:filmdeneme/widgets/movie_card.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';
import 'package:filmdeneme/pages/UserProfilePage.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/models/user.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService(apiKey: 'cefb463bcee27f953efce1ad0792525c');
  final UserService _userService = UserService();
  
  late TabController _tabController;
  Timer? _debounce;
  String _searchQuery = '';
  Map<SearchType, List<dynamic>> _searchResults = {
    SearchType.movies: [],
    SearchType.tvShows: [],
    SearchType.users: [],
  };
  Map<SearchType, bool> _isLoading = {
    SearchType.movies: false,
    SearchType.tvShows: false,
    SearchType.users: false,
  };
  Map<SearchType, String> _errorMessages = {
    SearchType.movies: '',
    SearchType.tvShows: '',
    SearchType.users: '',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() => _searchQuery = query);
        if (query.isNotEmpty) {
          _performSearch();
        } else {
          _clearResults();
        }
      }
    });
  }

  void _clearResults() {
    setState(() {
      for (var type in SearchType.values) {
        _searchResults[type] = [];
        _errorMessages[type] = '';
      }
    });
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    final currentType = SearchType.values[_tabController.index];
    setState(() => _isLoading[currentType] = true);

    try {
      switch (currentType) {
        case SearchType.movies:
          final results = await _apiService.searchMovies(_searchQuery);
          setState(() => _searchResults[SearchType.movies] = results);
          break;
        case SearchType.tvShows:
          final results = await _apiService.searchTVShows(_searchQuery);
          setState(() => _searchResults[SearchType.tvShows] = results);
          break;
        case SearchType.users:
          final results = await _userService.searchUsers(_searchQuery);
          setState(() => _searchResults[SearchType.users] = results);
          break;
      }
      setState(() => _errorMessages[currentType] = '');
    } catch (e) {
      setState(() => _errorMessages[currentType] = 'An error occurred while searching. Please try again.');
    } finally {
      setState(() => _isLoading[currentType] = false);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for movies, TV shows, or users',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.primaryColor),
                onPressed: () {
                  _searchController.clear();
                  _clearResults();
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.errorColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.search : Icons.mood_bad,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Start typing to search'
                : 'No results found',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              '@${user.username}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(userId: user.uid),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList(SearchType type) {
    if (_isLoading[type]!) {
      return _buildLoadingView();
    }

    if (_errorMessages[type]!.isNotEmpty) {
      return _buildErrorView(_errorMessages[type]!);
    }

    final results = _searchResults[type]!;
    if (results.isEmpty) {
      return _buildEmptyView();
    }

    if (type == SearchType.users) {
      return ListView.builder(
        itemCount: results.length,
        padding: const EdgeInsets.only(top: 8),
        itemBuilder: (context, index) => _buildUserCard(results[index] as AppUser),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.45,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${item['poster_path'] ?? ''}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              // Title and Rating
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == SearchType.movies ? item['title'] : item['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (item['vote_average'] ?? 0).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).asGestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  movieId: item['id'],
                  title: type == SearchType.movies ? item['title'] : item['name'],
                  overview: item['overview'] ?? 'No overview available',
                  posterPath: item['poster_path'] ?? '',
                  releaseDate: type == SearchType.movies 
                      ? (item['release_date'] ?? 'Unknown')
                      : (item['first_air_date'] ?? 'Unknown'),
                  director: 'Unknown',
                  actors: [],
                  isMovie: type == SearchType.movies,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _performSearch(),
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          labelColor: Colors.white, // Seçili tab yazısı rengi
          unselectedLabelColor: Colors.white70, // Seçili olmayan tab yazısı rengi
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'TV Shows'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: SearchType.values
                  .map((type) => _buildResultsList(type))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

}

enum SearchType {
  movies,
  tvShows,
  users,
}

extension GestureDetectorExtension on Widget {
  Widget asGestureDetector({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}
