class ApiService {
  final String apiKey;

  ApiService({required this.apiKey});

  Future<List> searchMovies(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&language=en-US&query=${Uri.encodeQueryComponent(query)}&page=$page&include_adult=false',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to search movies');
    }
  }
} 