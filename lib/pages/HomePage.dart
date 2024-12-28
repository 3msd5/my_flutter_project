import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/pages/profilePage.dart';
import 'package:filmdeneme/pages/loginPage.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List dailyMovies = [];
  List weeklyMovies = [];
  List dailyTvShows = [];
  List weeklyTvShows = [];
  bool isLoadingDaily = true;
  bool isLoadingWeekly = true;
  bool showDaily = true;
  bool isLoggedIn = false;
  bool isMovieSelected = true; // True for Movies, False for TV Shows

  @override
  void initState() {
    super.initState();
    fetchDailyMovies();
    fetchWeeklyMovies();
  }

  Future<void> fetchDailyMovies() async {
    setState(() {
      isLoadingDaily = true;
    });
    try {
      dailyMovies = await apiService.fetchTrendingMoviesDaily();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingDaily = false;
        });
      }
    }
  }

  Future<void> fetchWeeklyMovies() async {
    setState(() {
      isLoadingWeekly = true;
    });
    try {
      weeklyMovies = await apiService.fetchTrendingMoviesWeekly();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWeekly = false;
        });
      }
    }
  }

  Future<void> fetchDailyTvShows() async {
    setState(() {
      isLoadingDaily = true;
    });
    try {
      dailyTvShows = await apiService.fetchTrendingTVShowsDaily();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingDaily = false;
        });
      }
    }
  }

  Future<void> fetchWeeklyTvShows() async {
    setState(() {
      isLoadingWeekly = true;
    });
    try {
      weeklyTvShows = await apiService.fetchTrendingTVShowsWeekly();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWeekly = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trending Movies and TV Shows')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(isLoggedIn ? 'Kullanıcı Adı' : 'Misafir'),
              accountEmail: Text(isLoggedIn ? 'email@example.com' : 'Giriş Yap'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            ListTile(
              title: Text(isLoggedIn ? 'Bilgilerim' : 'Giriş Yap'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isLoggedIn ? ProfilePage() : LoginPage(),
                  ),
                );
              },
            ),
            if (isLoggedIn) ...[
              ListTile(
                title: Text('Favorilerim'),
                onTap: () {
                  // Favorilerim sayfasına yönlendirme
                },
              ),
              ListTile(
                title: Text('İzleme Listem'),
                onTap: () {
                  // İzleme Listem sayfasına yönlendirme
                },
              ),
            ]
          ],
        ),
      ),
      body: Column(
        children: [
          // Select Movie or TV Show
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isMovieSelected = true; // Select Movies
                  });
                  if (showDaily) {
                    fetchDailyMovies();
                  } else {
                    fetchWeeklyMovies();
                  }
                },
                child: Text('Filmler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isMovieSelected = false; // Select TV Shows
                  });
                  if (showDaily) {
                    fetchDailyTvShows();
                  } else {
                    fetchWeeklyTvShows();
                  }
                },
                child: Text('Diziler'),
              ),
            ],
          ),

          // Select Daily or Weekly Trends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDaily = true; // Show Daily Trends
                  });
                  if (isMovieSelected) {
                    fetchDailyMovies();
                  } else {
                    fetchDailyTvShows();
                  }
                },
                child: Text('Günlük Trendler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showDaily = false; // Show Weekly Trends
                  });
                  if (isMovieSelected) {
                    fetchWeeklyMovies();
                  } else {
                    fetchWeeklyTvShows();
                  }
                },
                child: Text('Haftalık Trendler'),
              ),
            ],
          ),

          // Displaying List
          Expanded(
            child: isLoadingDaily || isLoadingWeekly
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: isMovieSelected
                  ? (showDaily ? dailyMovies.length : weeklyMovies.length)
                  : (showDaily ? dailyTvShows.length : weeklyTvShows.length),
              itemBuilder: (context, index) {
                final item = isMovieSelected
                    ? (showDaily ? dailyMovies[index] : weeklyMovies[index])
                    : (showDaily ? dailyTvShows[index] : weeklyTvShows[index]);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          movieId: item['id'],
                          title: item['name'] ?? item['title'],
                          overview: item['overview'],
                          posterPath: item['poster_path'] ?? '',
                          releaseDate: item['release_date'] ?? 'Bilinmiyor',
                          director: item['director'] ?? 'Bilinmiyor',
                          actors: List<String>.from(item['actors'] ?? []),
                          isMovie: isMovieSelected,  // <-- Burada isMovie parametresini sağlıyoruz
                        ),
                      ),
                    );

                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['name'] ?? item['title'],  // Display name or title
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
