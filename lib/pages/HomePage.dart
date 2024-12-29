import 'package:flutter/material.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/pages/profilePage.dart';
import 'package:filmdeneme/pages/loginPage.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/widgets/movie_card.dart';
import 'package:filmdeneme/widgets/custom_toggle_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
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
      appBar: AppBar(
        title: const Text('MovieScout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Content Type Toggle (Movies/TV Shows)
                Center(
                  child: CustomToggleButtons(
                    options: const ['Movies', 'TV Shows'],
                    selectedIndex: isMovieSelected ? 0 : 1,
                    onSelected: (index) {
                      setState(() {
                        isMovieSelected = index == 0;
                      });
                      if (showDaily) {
                        isMovieSelected ? fetchDailyMovies() : fetchDailyTvShows();
                      } else {
                        isMovieSelected ? fetchWeeklyMovies() : fetchWeeklyTvShows();
                      }
                    },
                    leftIcon: Icons.movie_outlined,
                    rightIcon: Icons.tv_outlined,
                  ),
                ),
                const SizedBox(height: 8),
                // Time Period Toggle (Daily/Weekly)
                Center(
                  child: CustomToggleButtons(
                    options: const ['Daily Trends', 'Weekly Trends'],
                    selectedIndex: showDaily ? 0 : 1,
                    onSelected: (index) {
                      setState(() {
                        showDaily = index == 0;
                      });
                      if (isMovieSelected) {
                        showDaily ? fetchDailyMovies() : fetchWeeklyMovies();
                      } else {
                        showDaily ? fetchDailyTvShows() : fetchWeeklyTvShows();
                      }
                    },
                    leftIcon: Icons.today_outlined,
                    rightIcon: Icons.date_range_outlined,
                  ),
                ),
              ],
            ),
          ),

          // Content Grid
          Expanded(
            child: isLoadingDaily || isLoadingWeekly
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentColor,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: isMovieSelected
                        ? (showDaily ? dailyMovies.length : weeklyMovies.length)
                        : (showDaily ? dailyTvShows.length : weeklyTvShows.length),
                    itemBuilder: (context, index) {
                      final item = isMovieSelected
                          ? (showDaily ? dailyMovies[index] : weeklyMovies[index])
                          : (showDaily ? dailyTvShows[index] : weeklyTvShows[index]);
                      
                      return MovieCard(
                        title: item['name'] ?? item['title'],
                        posterPath: item['poster_path'] ?? '',
                        voteAverage: (item['vote_average'] ?? 0.0).toDouble(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                movieId: item['id'],
                                title: item['name'] ?? item['title'],
                                overview: item['overview'],
                                posterPath: item['poster_path'] ?? '',
                                releaseDate: item['release_date'] ?? 'Unknown',
                                director: item['director'] ?? 'Unknown',
                                actors: List<String>.from(item['actors'] ?? []),
                                isMovie: isMovieSelected,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
