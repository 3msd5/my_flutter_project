import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_lists.dart';
import '../widgets/movie_card.dart';
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

      setState(() {
        watchlist.removeWhere((item) => item.id == movie.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from watchlist'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing from watchlist: ${e.toString()}'),
            backgroundColor: Colors.red,
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
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving to favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
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
          ? const Center(child: CircularProgressIndicator())
          : watchlist.isEmpty
              ? const Center(
                  child: Text('No items in watchlist'),
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
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeFromWatchlist(movie);
                      },
                      child: Stack(
                        children: [
                          MovieCard(
                            title: movie.title,
                            posterPath: movie.posterPath ?? '',
                            voteAverage: movie.voteAverage,
                            overview: movie.overview,
                            movieId: movie.id,
                            isMovie: movie.isMovie,
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
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                              ),
                              onPressed: () => _moveToFavorites(movie),
                              tooltip: 'Move to favorites',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}