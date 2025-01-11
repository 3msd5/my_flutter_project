class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService(apiKey: 'YOUR_API_KEY'); // Ensure you replace 'YOUR_API_KEY' with your actual API key
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
      } else {
        setState(() {
          _searchResults.clear();
          _hasError = false;
          _errorMessage = '';
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      List results = await _apiService.searchMovies(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'An error occurred while searching. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: AppTheme.errorColor),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('No results found.'),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final movie = _searchResults[index];
          return MovieCard(
            title: movie['title'] ?? 'No Title',
            posterPath: movie['poster_path'] ?? '',
            voteAverage: (movie['vote_average'] ?? 0).toDouble(),
            overview: movie['overview'] ?? 'No Overview',
            releaseDate: movie['release_date'] ?? 'Unknown',
            isMovie: true, // Assuming these are movies; adjust as needed
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    movieId: movie['id'],
                    title: movie['title'] ?? 'No Title',
                    overview: movie['overview'] ?? 'No Overview',
                    posterPath: movie['poster_path'] ?? '',
                    releaseDate: movie['release_date'] ?? 'Unknown',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for movies or TV shows',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Search Results
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }
} 