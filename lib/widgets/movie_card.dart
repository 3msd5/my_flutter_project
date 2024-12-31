import 'package:flutter/material.dart';
import '../services/user_lists_service.dart';
import '../models/user_lists.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieCard extends StatefulWidget {
  final String title;
  final String posterPath;
  final double voteAverage;
  final VoidCallback onTap;
  final String overview;
  final String? releaseDate;
  final int movieId;
  final bool isMovie;

  const MovieCard({
    Key? key,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.onTap,
    required this.overview,
    this.releaseDate,
    required this.movieId,
    required this.isMovie,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  final UserListsService _userListsService = UserListsService();
  bool _isInFavorites = false;
  bool _isInWatchlist = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLists();
  }

  Future<void> _checkLists() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final inFavorites = await _userListsService.isInFavorites(widget.movieId);
      final inWatchlist = await _userListsService.isInWatchlist(widget.movieId);
      
      if (mounted) {
        setState(() {
          _isInFavorites = inFavorites;
          _isInWatchlist = inWatchlist;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add to favorites'),
        ),
      );
      return;
    }

    final movie = UserMovie(
      id: widget.movieId,
      title: widget.title,
      posterPath: widget.posterPath,
      voteAverage: widget.voteAverage,
      overview: widget.overview,
      releaseDate: widget.releaseDate,
      isMovie: widget.isMovie,
      addedAt: DateTime.now(),
    );

    await _userListsService.toggleFavorite(movie);
    await _checkLists();
  }

  Future<void> _toggleWatchlist() async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add to watchlist'),
        ),
      );
      return;
    }

    final movie = UserMovie(
      id: widget.movieId,
      title: widget.title,
      posterPath: widget.posterPath,
      voteAverage: widget.voteAverage,
      overview: widget.overview,
      releaseDate: widget.releaseDate,
      isMovie: widget.isMovie,
      addedAt: DateTime.now(),
    );

    await _userListsService.toggleWatchlist(movie);
    await _checkLists();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Image
                SizedBox(
                  width: 100,
                  height: 150,
                  child: widget.posterPath.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w200${widget.posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        ),
                ),
                // Movie Information
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!_isLoading && FirebaseAuth.instance.currentUser != null)
              Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isInFavorites ? Icons.favorite : Icons.favorite_border,
                        color: _isInFavorites ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                      tooltip: 'Add to favorites',
                    ),
                    IconButton(
                      icon: Icon(
                        _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                        color: _isInWatchlist ? Colors.blue : Colors.white,
                      ),
                      onPressed: _toggleWatchlist,
                      tooltip: 'Add to watchlist',
                    ),
                  ],
                ),
              ),
              ),
          ],
        ),
      ),
    );
  }
}
