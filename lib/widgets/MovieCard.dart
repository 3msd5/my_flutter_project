import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final String director;
  final List<String> actors;
  final bool isMovie;
  final VoidCallback onTap;

  const MovieCard({
    Key? key,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.director,
    required this.actors,
    required this.isMovie,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            // Poster Image
            Image.network(
              posterPath,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Release Date: $releaseDate'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Director: $director'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Cast: ${actors.join(', ')}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(overview, style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
