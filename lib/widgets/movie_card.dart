import 'package:flutter/material.dart';
import '../services/user_lists_service.dart';
import '../models/user_lists.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieCard extends StatefulWidget {
  final String title;
  final String posterPath;
  final double voteAverage;
  final String overview;
  final int movieId;
  final bool isMovie;
  final String? releaseDate;
  final VoidCallback? onTap;
  final VoidCallback? onListUpdated;

  const MovieCard({
    Key? key,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.overview,
    required this.movieId,
    required this.isMovie,
    this.releaseDate,
    this.onTap,
    this.onListUpdated,
  }) : super(key: key);

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  final _userListsService = UserListsService();
  bool _isInFavorites = false;
  bool _isInWatchlist = false;
  bool _isCheckingLists = true;

  @override
  void initState() {
    super.initState();
    _checkUserLists();
  }

  Future<void> _checkUserLists() async {
    if (mounted) {
      setState(() => _isCheckingLists = true);
    }

    try {
      final inFavorites = await _userListsService.isInFavorites(widget.movieId);
      final inWatchlist = await _userListsService.isInWatchlist(widget.movieId);

      if (mounted) {
        setState(() {
          _isInFavorites = inFavorites;
          _isInWatchlist = inWatchlist;
          _isCheckingLists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingLists = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      setState(() => _isInFavorites = !_isInFavorites);

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
      widget.onListUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInFavorites
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInFavorites = !_isInFavorites);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleWatchlist() async {
    try {
      setState(() => _isInWatchlist = !_isInWatchlist);

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
      widget.onListUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInWatchlist
                  ? 'Added to watchlist'
                  : 'Removed from watchlist',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInWatchlist = !_isInWatchlist);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating watchlist: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: widget.posterPath.isNotEmpty
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w200${widget.posterPath}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.movie,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.movie,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Movie Information
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                              Icons.star_rounded,
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
                        if (widget.releaseDate != null && widget.releaseDate!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.releaseDate!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!_isCheckingLists && FirebaseAuth.instance.currentUser != null)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: _isInFavorites ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: _isInFavorites ? Colors.red : Colors.grey[600]!,
                      onPressed: _toggleFavorite,
                      tooltip: 'Add to favorites',
                    ),
                    const SizedBox(width: 4),
                    _buildActionButton(
                      icon: _isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                      color: _isInWatchlist ? Colors.blue : Colors.grey[600]!,
                      onPressed: _toggleWatchlist,
                      tooltip: 'Add to watchlist',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
