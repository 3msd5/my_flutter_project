import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_lists.dart';
import '../widgets/movie_card.dart';
import '../theme/app_theme.dart';
import 'DetailsPage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  List<UserMovie> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      setState(() {
        favorites = snapshot.docs
            .map((doc) => UserMovie.fromMap(doc.data()))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(UserMovie movie) async {
    if (currentUser == null) return;

    // Remove from local state immediately
    setState(() {
      favorites.removeWhere((item) => item.id == movie.id);
    });

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('favorites')
          .where('id', isEqualTo: movie.id)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert local state if operation failed
      setState(() {
        favorites.add(movie);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing from favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No favorites added yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final movie = favorites[index];
                    return Dismissible(
                      key: Key(movie.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeFromFavorites(movie);
                      },
                      child: MovieCard(
                        title: movie.title,
                        posterPath: movie.posterPath ?? '',
                        voteAverage: movie.voteAverage,
                        overview: movie.overview,
                        movieId: movie.id,
                        isMovie: movie.isMovie,
                        releaseDate: movie.releaseDate,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                movieId: movie.id,
                                title: movie.title,
                                overview: movie.overview,
                                posterPath: movie.posterPath ?? '',
                                releaseDate: movie.releaseDate ?? 'Unknown',
                                director: 'Unknown',
                                actors: [],
                                isMovie: movie.isMovie,
                              ),
                            ),
                          );
                        },
                        onListUpdated: () {
                          // Refresh the favorites when the movie card's state changes
                          _loadFavorites();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}