class UserMovie {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String overview;
  final String? releaseDate;
  final bool isMovie; // to distinguish between movies and TV shows
  final DateTime addedAt;

  UserMovie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    required this.overview,
    this.releaseDate,
    required this.isMovie,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'voteAverage': voteAverage,
      'overview': overview,
      'releaseDate': releaseDate,
      'isMovie': isMovie,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory UserMovie.fromMap(Map<String, dynamic> map) {
    return UserMovie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      voteAverage: map['voteAverage'].toDouble(),
      overview: map['overview'],
      releaseDate: map['releaseDate'],
      isMovie: map['isMovie'],
      addedAt: DateTime.parse(map['addedAt']),
    );
  }
}