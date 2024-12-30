import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/widgets/info_section.dart';
import 'package:filmdeneme/widgets/production_companies.dart';
import 'package:filmdeneme/widgets/movie_info.dart';
import 'package:filmdeneme/widgets/tv_show_info.dart';

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
  late Future<Map<String, dynamic>> mediaData;
  bool _isRetrying = false;
  final ApiService _apiService = ApiService(apiKey: 'cefb463bcee27f953efce1ad0792525c');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      mediaData = _apiService.fetchMovieDetailsWithCredits(widget.movieId, isMovie: widget.isMovie);
    });
  }

  Future<void> _retryLoad() async {
    setState(() {
      _isRetrying = true;
    });
    
    await _loadData();
    
    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: mediaData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.accentColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading details...',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load details',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isRetrying ? null : _retryLoad,
                    icon: _isRetrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isRetrying ? 'Retrying...' : 'Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'poster_${widget.posterPath}',
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${widget.posterPath}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.cardColor,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: AppTheme.secondaryTextColor,
                                    size: 64,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black87,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(data['vote_average'] ?? 0.0).toStringAsFixed(1)}/10',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              widget.isMovie
                                  ? data['release_date'] ?? 'Unknown'
                                  : data['first_air_date'] ?? 'Unknown',
                              style: const TextStyle(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          data['overview'] ?? 'No description available.',
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const Divider(color: AppTheme.cardColor),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Information',
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            InfoSection(
                              icon: Icons.movie,
                              title: widget.isMovie ? 'Runtime' : 'Episode Runtime',
                              content: widget.isMovie
                                  ? (data['runtime'] != null
                                      ? '${data['runtime']} minutes'
                                      : 'Unknown')
                                  : (data['episode_run_time'] != null && data['episode_run_time'].isNotEmpty
                                      ? '${data['episode_run_time'][0]} minutes per episode'
                                      : 'Unknown'),
                            ),
                            InfoSection(
                              icon: Icons.person,
                              title: widget.isMovie ? 'Director' : 'Creator',
                              content: data['director'] ?? 'Unknown',
                            ),
                            InfoSection(
                              icon: Icons.language,
                              title: 'Original Language',
                              content:
                                  data['original_language']?.toUpperCase() ?? 'Unknown Language',
                            ),
                            InfoSection(
                              icon: Icons.local_movies,
                              title: 'Status',
                              content: data['status'] ?? 'Unknown',
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Additional Details',
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            widget.isMovie
                                ? MovieInfo(data: data)
                                : TVShowInfo(data: data),
                          ],
                        ),
                      ),
                      if (data['genres'] != null && data['genres'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Genres',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var genre in data['genres'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        genre['name'],
                                        style: const TextStyle(
                                          color: AppTheme.textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (data['production_companies'] != null &&
                          (data['production_companies'] as List).isNotEmpty)
                        ProductionCompanies(
                          companies: data['production_companies'] as List,
                        ),
                      if (data['cast'] != null && data['cast'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cast',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (var actor in data['cast'])
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        actor['name'],
                                        style: const TextStyle(
                                          color: AppTheme.textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.movie_filter,
                    color: AppTheme.secondaryTextColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.isMovie ? 'movie' : 'TV show'} details available',
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The requested content could not be found',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
