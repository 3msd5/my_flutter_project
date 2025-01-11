import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_lists.dart';
import '../widgets/movie_card.dart';
import '../theme/app_theme.dart';
import 'DetailsPage.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key}) : super(key: key);

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  List<UserMovie> watchlist = [];

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('watchlist')
          .orderBy('addedAt', descending: true)
          .get();

      setState(() {
        watchlist = snapshot.docs
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
            content: Text('Error loading watchlist: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFromWatchlist(UserMovie movie) async {
    if (currentUser == null) return;

    // Remove from local state immediately
    setState(() {
      watchlist.removeWhere((item) => item.id == movie.id);
    });

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('watchlist')
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
            content: Text('Removed from watchlist'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Revert local state if operation failed
      setState(() {
        watchlist.add(movie);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing from watchlist: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _moveToFavorites(UserMovie movie) async {
    if (currentUser == null) return;

    try {
      // Add to favorites
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('favorites')
          .add(movie.toMap());

      // Remove from watchlist
      await _removeFromWatchlist(movie);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Moved to favorites'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving to favorites: ${e.toString()}'),
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
        title: const Text('My Watchlist'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : watchlist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your watchlist is empty',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Movies you want to watch later will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: watchlist.length,
                  itemBuilder: (context, index) {
                    final movie = watchlist[index];
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
                        _removeFromWatchlist(movie);
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
                          // Refresh the watchlist when the movie card's state changes
                          _loadWatchlist();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}