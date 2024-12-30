import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey;

  ApiService({required this.apiKey});

  // Trend verilerini al (Film ya da Dizi)
  Future<List> _fetchTrending(String type, String timePeriod, {int page = 1}) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/trending/$type/$timePeriod?api_key=$apiKey&language=en-US&region=US&page=$page',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['results'];
      for (var item in data) {
        if (type == 'movie' && !item.containsKey('title')) {
          item['title'] = item['original_title'] ?? 'Unknown';
        }
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
  Future<List> fetchTrendingMoviesDaily({int page = 1}) async {
    return _fetchTrending('movie', 'day', page: page);
  }

  // Trend film ve dizileri al (haftalık)
  Future<List> fetchTrendingMoviesWeekly({int page = 1}) async {
    return _fetchTrending('movie', 'week', page: page);
  }

  // Trend dizileri al (günlük)
  Future<List> fetchTrendingTVShowsDaily({int page = 1}) async {
    return _fetchTrending('tv', 'day', page: page);
  }

  // Trend dizileri al (haftalık)
  Future<List> fetchTrendingTVShowsWeekly({int page = 1}) async {
    return _fetchTrending('tv', 'week', page: page);
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
      data['name'] = data['name'] ?? data['original_name'] ?? 'Unknown TV Show';
      data['poster_path'] ??= '/placeholder.png';
      data['first_air_date'] ??= 'Unknown First Air Date';
      data['overview'] ??= 'No overview available';
      data['status'] ??= 'Unknown Status';
      data['original_language'] ??= 'Unknown Language';
      data['vote_average'] ??= 0.0;
      data['runtime'] ??= 0;

      if (data['episode_run_time'] != null && data['episode_run_time'].isNotEmpty) {
        data['runtime'] = data['episode_run_time'][0];
      } else {
        data['runtime'] = 0;
      }

      data['director'] = data['created_by'] != null && data['created_by'].isNotEmpty
          ? data['created_by'].map((creator) => creator['name']).join(', ')
          : 'Unknown';

      final cast = data['credits']['cast'] ?? [];
      for (var actor in cast) {
        actor['name'] ??= 'Unknown Actor';
        actor['character'] ??= 'Unknown Character';
        actor['profile_path'] ??= '/placeholder.png';
      }
      data['cast'] = cast;

      if (data['genres'] == null) {
        data['genres'] = [];
      }

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
        'https://api.themoviedb.org/3/$type/$movieId?api_key=$apiKey&language=en-US&append_to_response=credits,created_by',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      try {
        // Basic information
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
        
        // Handle runtime differently for movies and TV shows
        if (isMovie) {
          data['runtime'] = data['runtime'] ?? 0;
        } else {
          if (data['episode_run_time'] is List && data['episode_run_time'].isNotEmpty) {
            data['runtime'] = data['episode_run_time'][0];
          } else {
            data['runtime'] = 0;
          }
        }

        // Handle director/creator
        if (isMovie) {
          final crew = data['credits']?['crew'] ?? [];
          final directors = crew.where((member) => member['job'] == 'Director').toList();
          data['director'] = directors.isNotEmpty ? directors[0]['name'] : 'Unknown';
        } else {
          if (data['created_by'] is List && data['created_by'].isNotEmpty) {
            final creators = data['created_by'].map((creator) => creator['name']).toList();
            data['director'] = creators.join(', ');
          } else {
            data['director'] = 'Unknown';
          }
        }

        // Handle cast
        final cast = data['credits']?['cast'] ?? [];
        final processedCast = [];
        for (var actor in cast) {
          if (actor != null) {
            processedCast.add({
              'name': actor['name'] ?? 'Unknown Actor',
              'character': actor['character'] ?? 'Unknown Character',
              'profile_path': actor['profile_path'] ?? '/placeholder.png'
            });
          }
        }
        data['cast'] = processedCast;

        // Ensure genres is always a list
        if (data['genres'] == null) {
          data['genres'] = [];
        }

        return data;
      } catch (e) {
        print('Error processing ${isMovie ? 'movie' : 'TV show'} data: $e');
        throw Exception('Failed to process ${isMovie ? 'movie' : 'TV show'} details');
      }
    } else {
      throw Exception('Failed to load ${isMovie ? 'movie' : 'TV show'} details');
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
      data['name'] = data['name'] ?? data['original_name'] ?? 'Unknown TV Show';
      data['poster_path'] ??= '/placeholder.png';
      data['first_air_date'] ??= 'Unknown First Air Date';
      data['overview'] ??= 'No overview available';
      data['status'] ??= 'Unknown Status';
      data['original_language'] ??= 'Unknown Language';
      data['vote_average'] ??= 0.0;

      // Handle episode runtime
      if (data['episode_run_time'] != null && data['episode_run_time'].isNotEmpty) {
        data['runtime'] = data['episode_run_time'][0];
      } else {
        data['runtime'] = 0;
      }

      // Handle creators
      if (data['created_by'] != null && data['created_by'].isNotEmpty) {
        data['director'] = data['created_by'].map((creator) => creator['name']).join(', ');
      } else {
        data['director'] = 'Unknown';
      }

      // Handle cast
      final cast = data['credits']['cast'] ?? [];
      for (var actor in cast) {
        actor['name'] ??= 'Unknown Actor';
        actor['character'] ??= 'Unknown Character';
        actor['profile_path'] ??= '/placeholder.png';
      }
      data['cast'] = cast;

      // Handle genres
      if (data['genres'] == null) {
        data['genres'] = [];
      }

      return data;
    } else {
      throw Exception('Failed to load TV show details with credits');
    }
  }
}
