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

  @override
  void initState() {
    super.initState();
    mediaData = ApiService().fetchMovieDetailsWithCredits(widget.movieId, isMovie: widget.isMovie);
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
                        Hero(
                          tag: 'poster_${widget.posterPath}',
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${widget.posterPath}',
                            fit: BoxFit.cover,
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
                                  data['original_language']?.toUpperCase() ?? 'Unknown',
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
