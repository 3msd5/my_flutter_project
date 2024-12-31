import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_lists.dart';

class UserListsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<bool> isInFavorites(int movieId) async {
    if (currentUser == null) return false;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favorites')
        .where('id', isEqualTo: movieId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<bool> isInWatchlist(int movieId) async {
    if (currentUser == null) return false;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('watchlist')
        .where('id', isEqualTo: movieId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> toggleFavorite(UserMovie movie) async {
    if (currentUser == null) return;

    final isAlreadyFavorite = await isInFavorites(movie.id);

    if (isAlreadyFavorite) {
      // Remove from favorites
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
    } else {
      // Add to favorites
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('favorites')
          .add(movie.toMap());

      // If it's in watchlist, remove it from there
      await removeFromWatchlist(movie.id);
    }
  }

  Future<void> toggleWatchlist(UserMovie movie) async {
    if (currentUser == null) return;

    final isAlreadyInWatchlist = await isInWatchlist(movie.id);

    if (isAlreadyInWatchlist) {
      await removeFromWatchlist(movie.id);
    } else {
      // Add to watchlist
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('watchlist')
          .add(movie.toMap());

      // If it's in favorites, remove it from there
      await removeFromFavorites(movie.id);
    }
  }

  Future<void> removeFromFavorites(int movieId) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favorites')
        .where('id', isEqualTo: movieId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> removeFromWatchlist(int movieId) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('watchlist')
        .where('id', isEqualTo: movieId)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}