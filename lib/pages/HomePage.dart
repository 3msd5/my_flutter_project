import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:filmdeneme/services/api_service.dart';
import 'package:filmdeneme/pages/profilePage.dart';
import 'package:filmdeneme/pages/loginPage.dart';
import 'package:filmdeneme/pages/DetailsPage.dart';
import 'package:filmdeneme/pages/SearchPage.dart';
import 'package:filmdeneme/theme/app_theme.dart';
import 'package:filmdeneme/widgets/movie_card.dart';
import 'package:filmdeneme/widgets/custom_toggle_buttons.dart';
import 'package:filmdeneme/pages/favorites_page.dart';
import 'package:filmdeneme/pages/watchlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService(apiKey: 'cefb463bcee27f953efce1ad0792525c');
  final ScrollController _scrollController = ScrollController();
  List dailyMovies = [];
  List weeklyMovies = [];
  List dailyTvShows = [];
  List weeklyTvShows = [];
  bool isLoadingDaily = true;
  bool isLoadingWeekly = true;
  bool showDaily = true;
  bool isMovieSelected = true;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreItems = true;
  User? currentUser;

  late final StreamSubscription<User?> _authSubscription;
  String _userFullName = '';

  Future<void> _getUserFullNameFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userFullName = userDoc['name'] ?? 'Kullanıcı';
        });
      }
    }
  }

  String _getUserFullName() {
    return _userFullName.isNotEmpty ? _userFullName : 'Kullanıcı';
  }
  @override
  void initState() {
    super.initState();
    _getUserFullNameFromFirestore(); // Kullanıcı adını almak için çağrılıyor
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (mounted) {
            setState(() {
              currentUser = user;
            });

            if (user == null && context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
              );
            }
          }
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _authSubscription.cancel();
    dailyMovies.clear();
    weeklyMovies.clear();
    dailyTvShows.clear();
    weeklyTvShows.clear();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoadingDaily = true;
      isLoadingWeekly = true;
      currentPage = 1;
      hasMoreItems = true;
    });
    await _fetchData();
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore || !hasMoreItems) return;
    
    setState(() {
      isLoadingMore = true;
      currentPage++;
    });
    
    await _fetchData();
    
    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _fetchData() async {
    try {
      if (isMovieSelected) {
        if (showDaily) {
          final newMovies = await apiService.fetchTrendingMoviesDaily(page: currentPage);
          if (mounted) {
            setState(() {
              dailyMovies.addAll(newMovies);
              hasMoreItems = newMovies.isNotEmpty;
            });
          }
        } else {
          final newMovies = await apiService.fetchTrendingMoviesWeekly(page: currentPage);
          setState(() {
            weeklyMovies.addAll(newMovies);
            hasMoreItems = newMovies.isNotEmpty;
          });
        }
      } else {
        if (showDaily) {
          final newShows = await apiService.fetchTrendingTVShowsDaily(page: currentPage);
          setState(() {
            dailyTvShows.addAll(newShows);
            hasMoreItems = newShows.isNotEmpty;
          });
        } else {
          final newShows = await apiService.fetchTrendingTVShowsWeekly(page: currentPage);
          setState(() {
            weeklyTvShows.addAll(newShows);
            hasMoreItems = newShows.isNotEmpty;
          });
        }
      }
    } catch (e) {
      setState(() {
        hasMoreItems = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingDaily = false;
          isLoadingWeekly = false;
        });
      }
    }
  }

  Widget _buildContent() {
    final items = isMovieSelected
        ? (showDaily ? dailyMovies : weeklyMovies)
        : (showDaily ? dailyTvShows : weeklyTvShows);

    if (items.isEmpty && !isLoadingDaily && !isLoadingWeekly) {
      return const Center(
        child: Text('No items found'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            itemCount: items.length + (hasMoreItems ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: hasMoreItems
                        ? const CircularProgressIndicator()
                        : const Text('No more items to load'),
                  ),
                );
              }

              final item = items[index];
              return MovieCard(
                title: item['name'] ?? item['title'],
                posterPath: item['poster_path'] ?? '',
                voteAverage: (item['vote_average'] ?? 0.0).toDouble(),
                overview: item['overview'] ?? '',
                movieId: item['id'],
                isMovie: isMovieSelected,
                releaseDate: isMovieSelected 
                    ? item['release_date'] ?? 'Unknown'
                    : item['first_air_date'] ?? 'Unknown',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(
                        movieId: item['id'],
                        title: item['name'] ?? item['title'],
                        overview: item['overview'] ?? 'No overview available',
                        posterPath: item['poster_path'] ?? '',
                        releaseDate: isMovieSelected 
                            ? (item['release_date'] ?? 'Unknown')
                            : (item['first_air_date'] ?? 'Unknown'),
                        director: 'Unknown',
                        actors: [],
                        isMovie: isMovieSelected,
                      ),
                    ),
                  );
                  
                  // Refresh the current list when returning from details page
                  _fetchInitialData();
                },
                onListUpdated: () {
                  // Refresh the current list when favorites/watchlist is updated
                  _fetchInitialData();
                },
              );
            },
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
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
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser != null
                    ? _getUserFullName()
                    : 'Welcome! Please login.',
                style: const TextStyle(fontSize: 16),
              ),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: currentUser != null && currentUser!.photoURL != null
                    ? NetworkImage(currentUser!.photoURL!)
                    : null,
                child: currentUser != null && currentUser!.photoURL == null
                    ? const Icon(Icons.person, color: Colors.blue, size: 40)
                    : null,
              ),
            ),
            if (currentUser != null) ...[
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('My Favorites'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('My Watchlist'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WatchlistPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logout failed: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
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
                        _fetchInitialData();
                      });
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
                        _fetchInitialData();
                      });
                    },
                    leftIcon: Icons.today_outlined,
                    rightIcon: Icons.date_range_outlined,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingDaily || isLoadingWeekly
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentColor,
                    ),
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }
}
