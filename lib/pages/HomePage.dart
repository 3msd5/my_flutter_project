import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/pages/profilePage.dart';
import 'package:filmdeneme/pages/loginPage.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';
import 'package:filmdeneme/pages/SearchPage.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                final isLoggedIn = user != null;

                return Column(
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        isLoggedIn ? (user.displayName ?? 'User') : 'Guest',
                        style: const TextStyle(fontSize: 16),
                      ),
                      accountEmail: Text(
                        isLoggedIn ? user.email! : 'Sign in to access more features',
                        style: const TextStyle(fontSize: 14),
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: isLoggedIn && user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: isLoggedIn && user.photoURL == null
                            ? const Icon(Icons.person, color: Colors.blue, size: 40)
                            : null,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(isLoggedIn ? 'My Profile' : 'Sign In'),
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
                        leading: const Icon(Icons.favorite_border),
                        title: const Text('My Favorites'),
                        onTap: () {
                          // Favorites page navigation
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.list_alt),
                        title: const Text('Watch List'),
                        onTap: () {
                          // Watch list page navigation
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
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
