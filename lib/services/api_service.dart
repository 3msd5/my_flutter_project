import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = 'cefb463bcee27f953efce1ad0792525c';

  // Trend verilerini al (Film ya da Dizi)
  Future<List> _fetchTrending(String type, String timePeriod) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/trending/$type/$timePeriod?api_key=$apiKey&language=en-US&region=US',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      // Don't set default values for title/name as they come from the API
      for (var item in data) {
        // For movies, use 'title' field
        if (type == 'movie' && !item.containsKey('title')) {
          item['title'] = item['original_title'] ?? 'Unknown';
        }
        // For TV shows, use 'name' field
        if (type == 'tv' && !item.containsKey('name')) {
          item['name'] = item['original_name'] ?? 'Unknown';
        }
        item['poster_path'] ??= '/placeholder.png';
      }
      return data;
    } else {
      throw Exception('Failed to load trending $type');
    }
  }

  // Trend film ve dizileri al (günlük)
  Future<List> fetchTrendingMoviesDaily() async {
    return _fetchTrending('movie', 'day');
  }

  // Trend film ve dizileri al (haftalık)
  Future<List> fetchTrendingMoviesWeekly() async {
    return _fetchTrending('movie', 'week');
  }

  // Trend dizileri al (günlük)
  Future<List> fetchTrendingTVShowsDaily() async {
    return _fetchTrending('tv', 'day');
  }

  // Trend dizileri al (haftalık)
  Future<List> fetchTrendingTVShowsWeekly() async {
    return _fetchTrending('tv', 'week');
  }

  // Film detaylarını al
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=en-US',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Use original_title as fallback before using default value
      data['title'] = data['title'] ?? data['original_title'] ?? 'Unknown Movie';
      data['poster_path'] ??= '/placeholder.png';
      data['release_date'] ??= 'Unknown Release Date';
      data['overview'] ??= 'No overview available';
      data['status'] ??= 'Unknown Status';
      data['original_language'] ??= 'Unknown Language';
      data['vote_average'] ??= 0.0;
      data['runtime'] ??= 0;
      return data;
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  // Dizi detaylarını al
  Future<Map<String, dynamic>> fetchTVShowDetails(int tvShowId) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/tv/$tvShowId?api_key=$apiKey&language=en-US',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Use original_name as fallback before using default value
      data['name'] = data['name'] ?? data['original_name'] ?? 'Unknown TV Show';
      data['poster_path'] ??= '/placeholder.png';
      data['first_air_date'] ??= 'Unknown First Air Date';
      data['overview'] ??= 'No overview available';
      data['status'] ??= 'Unknown Status';
      data['original_language'] ??= 'Unknown Language';
      data['vote_average'] ??= 0.0;
      return data;
    } else {
      throw Exception('Failed to load TV show details');
    }
  }

  // Film araması yap
  Future<List> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&language=en-US',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      // Process search results to ensure titles are present
      for (var item in data) {
        item['title'] = item['title'] ?? item['original_title'] ?? 'Unknown';
        item['poster_path'] ??= '/placeholder.png';
      }
      return data;
    } else {
      throw Exception('Failed to search movies');
    }
  }

  // Dizi araması yap
  Future<List> searchTVShows(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/search/tv?api_key=$apiKey&query=$query&language=en-US',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      // Process search results to ensure names are present
      for (var item in data) {
        item['name'] = item['name'] ?? item['original_name'] ?? 'Unknown';
        item['poster_path'] ??= '/placeholder.png';
      }
      return data;
    } else {
      throw Exception('Failed to search TV shows');
    }
  }

  // Film detaylarını ve oyuncuları al
  Future<Map<String, dynamic>> fetchMovieDetailsWithCredits(int movieId, {bool isMovie = true}) async {
    final type = isMovie ? 'movie' : 'tv';
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/$type/$movieId?api_key=$apiKey&language=en-US&append_to_response=credits',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Film verileri - use original_title as fallback
      data['title'] = isMovie 
          ? (data['title'] ?? data['original_title'] ?? 'Unknown Movie')
          : (data['name'] ?? data['original_name'] ?? 'Unknown TV Show');
      data['poster_path'] ??= '/placeholder.png';
      data['release_date'] = isMovie 
          ? (data['release_date'] ?? 'Unknown Release Date')
          : (data['first_air_date'] ?? 'Unknown Release Date');
      data['overview'] ??= 'No overview available';
      data['status'] ??= 'Unknown Status';
      data['original_language'] ??= 'Unknown Language';
      data['vote_average'] ??= 0.0;
      data['runtime'] ??= 0;

      // Get director from crew
      final crew = data['credits']['crew'] ?? [];
      final directors = crew.where((member) => member['job'] == 'Director').toList();
      data['director'] = directors.isNotEmpty ? directors[0]['name'] : 'Unknown';

      // Oyuncu bilgileri
      final cast = data['credits']['cast'] ?? [];
      for (var actor in cast) {
        actor['name'] ??= 'Unknown Actor';
        actor['character'] ??= 'Unknown Character';
        actor['profile_path'] ??= '/placeholder.png';
      }
      data['cast'] = cast;

      // For TV shows, also check for created by
      if (!isMovie && data['created_by'] != null && data['created_by'].isNotEmpty) {
        final creators = data['created_by'].map((creator) => creator['name']).join(', ');
        data['director'] = creators;
      }

      return data;
    } else {
      throw Exception('Failed to load movie details with credits');
    }
  }

  // Dizi detaylarını ve oyuncuları al
  Future<Map<String, dynamic>> fetchTVShowDetailsWithCredits(int tvShowId) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/tv/$tvShowId?api_key=$apiKey&language=en-US&append_to_response=credits',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Dizi verileri - use original_name as fallback
      data['name'] = data['name'] ?? data['original_name'] ?? 'Unknown TV Show';
      data['poster_path'] ??= '/placeholder.png';
      data['first_air_date'] ??= 'Unknown First Air Date';
      data['overview'] ??= 'No overview available';
      data['status'] ??= 'Unknown Status';
      data['original_language'] ??= 'Unknown Language';
      data['vote_average'] ??= 0.0;

      // Oyuncu bilgileri
      final cast = data['credits']['cast'] ?? [];
      for (var actor in cast) {
        actor['name'] ??= 'Unknown Actor';
        actor['character'] ??= 'Unknown Character';
        actor['profile_path'] ??= '/placeholder.png';
      }
      data['cast'] = cast;

      return data;
    } else {
      throw Exception('Failed to load TV show details with credits');
    }
  }
}
