import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart';

// This is a test widget to view all API data
class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({Key? key}) : super(key: key);

  @override
  _ApiTestWidgetState createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _movieData;
  Map<String, dynamic>? _tvData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Test with popular movie and TV show IDs
      _movieData = await _apiService.fetchMovieDetailsWithCredits(550, isMovie: true); // Fight Club
      _tvData = await _apiService.fetchMovieDetailsWithCredits(93405, isMovie: false); // Squid Game
    } catch (e) {
      print('Error fetching data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Data Test')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Movie Data:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_movieData?.toString() ?? 'No data'),
                    const SizedBox(height: 32),
                    const Text('TV Show Data:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_tvData?.toString() ?? 'No data'),
                  ],
                ),
              ),
            ),
    );
  }
}
