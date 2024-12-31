import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_lists.dart';
import '../widgets/movie_card.dart';
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
          ),
        );
      }
    }
  }

  Future<void> _removeFromFavorites(UserMovie movie) async {
    if (currentUser == null) return;

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

      setState(() {
        favorites.removeWhere((item) => item.id == movie.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing from favorites: ${e.toString()}'),
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
        title: const Text('My Favorites'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(
                  child: Text('No favorites added yet'),
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
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
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
                    );
                  },
                ),
    );
  }
}