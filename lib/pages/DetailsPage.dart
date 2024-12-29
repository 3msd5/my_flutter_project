import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/widgets/info_section.dart';

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
    movieData = ApiService().fetchMovieDetailsWithCredits(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: movieData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.textColor),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return CustomScrollView(
              slivers: <Widget>[
                // App Bar with Backdrop
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Backdrop Image
                        Hero(
                          tag: 'poster_${widget.posterPath}',
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${widget.posterPath}',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient Overlay
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
                // Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating and Release Date Row
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
                              data['release_date'] ?? 'Unknown',
                              style: const TextStyle(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Overview
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

                      // Info Sections
                      InfoSection(
                        icon: Icons.movie,
                        title: 'Runtime',
                        content: data['runtime'] != null
                            ? '${data['runtime']} minutes'
                            : 'Unknown',
                      ),

                      InfoSection(
                        icon: Icons.person,
                        title: 'Director',
                        content: data['director'] ?? 'Unknown',
                      ),

                      InfoSection(
                        icon: Icons.language,
                        title: 'Original Language',
                        content:
                            data['original_language']?.toUpperCase() ?? 'Unknown',
                      ),

                      InfoSection(
                        icon: Icons.local_movies,
                        title: 'Status',
                        content: data['status'] ?? 'Unknown',
                      ),

                      // Genres
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

                      // Cast
                      if (data['actors'] != null && data['actors'].isNotEmpty)
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
                                  for (var actor in data['actors'])
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
                                        actor,
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
            return const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppTheme.textColor),
              ),
            );
          }
        },
      ),
    );
  }
}
