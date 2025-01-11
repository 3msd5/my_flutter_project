import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  Future<List<DocumentSnapshot>> _getMoviesFromCollection(String collectionName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collectionName)
        .get();
    return querySnapshot.docs;
  }

  Future<DocumentSnapshot> _getUserData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  Widget _buildMovieCard(Map<String, dynamic> movie, BuildContext context) {
    final posterPath = movie['posterPath'];
    final posterUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
              movieId: movie['id'],
              title: movie['title'] ?? 'Unknown',
              overview: movie['overview'] ?? 'No overview available',
              posterPath: movie['posterPath'] ?? '',
              releaseDate: movie['releaseDate'] ?? 'Unknown',
              director: movie['director'] ?? 'Unknown',
              actors: List<String>.from(movie['actors'] ?? []),
              isMovie: movie['isMovie'] ?? true,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: posterUrl != null
                  ? Image.network(
                      posterUrl,
                      height: 180,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 180,
                            width: 120,
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                          ),
                    )
                  : Container(
                      height: 180,
                      width: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              movie['title'] ?? 'No title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<DocumentSnapshot> movies, BuildContext context) {
    if (movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No $title yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (context, index) => _buildMovieCard(
                movies[index].data() as Map<String, dynamic>,
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          _getUserData(),
          _getMoviesFromCollection('favorites'),
          _getMoviesFromCollection('watchlist'),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data![0].data() as Map<String, dynamic>;
          final favoriteMovies = snapshot.data![1];
          final watchlistMovies = snapshot.data![2];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    userData['name'] ?? 'User Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Text(
                                      (userData['name'] as String).isNotEmpty
                                          ? userData['name'][0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '@${userData['username'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userData['email'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildSection('Favorites', favoriteMovies, context),
                      _buildSection('Watchlist', watchlistMovies, context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
