import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() {
  runApp(const StreamifyApp());
}

class StreamifyApp extends StatelessWidget {
  const StreamifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: Colors.redAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amber,
        ),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const SubscriptionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF161616),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white60,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'Go Premium'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String apiKey = '6648327a11d56b365137fcb154100589';
  List<dynamic> trendingMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies();
  }

  Future<void> fetchTrendingMovies() async {
    final url = Uri.parse('https://api.themoviedb.org/3/trending/movie/day?api_key=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          trendingMovies = data['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Streamify',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionRow(context, 'Hollywood Dual Audio (Hindi)', trendingMovies, 'movie'),
                  _buildSectionRow(context, 'Bollywood & South Movies', trendingMovies.reversed.toList(), 'movie'),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionRow(BuildContext context, String title, List movies, String contentType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final posterPath = movie['poster_path'];
                final imageUrl = posterPath != null
                    ? 'https://image.tmdb.org/t/p/w500$posterPath'
                    : '';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          itemData: movie,
                          contentType: contentType,
                          suggestionsList: movies,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: Colors.grey[900], child: const Icon(Icons.broken_image)),
                                  )
                                : Container(color: Colors.grey[900], child: const Icon(Icons.movie)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          movie['title'] ?? movie['name'] ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Text(
                          'Dual Audio',
                          style: TextStyle(color: Colors.amber, fontSize: 10),
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

// Search Screen for finding movies and shows
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String apiKey = '6648327a11d56b365137fcb154100589';
  List<dynamic> searchResults = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final url = Uri.parse('https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data['results'].where((item) => item['media_type'] != 'person').toList();
          isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search movies, shows, anime...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: performSearch,
        ),
        backgroundColor: Colors.black,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                performSearch('');
              },
            ),
        ],
      ),
      body: isSearching
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Search for your favorite movies & series',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    final posterPath = item['poster_path'];
                    final imageUrl = posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
                    final mediaType = item['media_type'] ?? 'movie';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              itemData: item,
                              contentType: mediaType,
                              suggestionsList: searchResults,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                                  : Container(color: Colors.grey[900], child: const Icon(Icons.movie)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['title'] ?? item['name'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// Detail Screen with Player and Specific Suggestions
class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String contentType;
  final List<dynamic> suggestionsList;

  const DetailScreen({
    super.key,
    required this.itemData,
    required this.contentType,
    required this.suggestionsList,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late VideoPlayerController _videoController;
  bool isPlayingVideo = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-video-assets/bees.mp4'),
    )..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void toggleFullScreen() {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemData['title'] ?? widget.itemData['name'] ?? 'Title';
    final backdropPath = widget.itemData['backdrop_path'];
    final overview = widget.itemData['overview'] ?? 'No description available.';
    final releaseDate = widget.itemData['release_date'] ?? widget.itemData['first_air_date'] ?? 'N/A';
    final rating = widget.itemData['vote_average']?.toString() ?? 'N/A';
    final backdropUrl = backdropPath != null ? 'https://image.tmdb.org/t/p/w500$backdropPath' : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isPlayingVideo
                ? Container(
                    height: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height : 230,
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Center(
                          child: _videoController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                )
                              : const CircularProgressIndicator(color: Colors.redAccent),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(Icons.fullscreen, color: Colors.white, size: 30),
                            onPressed: toggleFullScreen,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 230,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: backdropUrl.isNotEmpty
                          ? DecorationImage(image: NetworkImage(backdropUrl), fit: BoxFit.cover)
                          : null,
                      color: Colors.grey[900],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_filled, size: 70, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            isPlayingVideo = true;
                            _videoController.play();
                          });
                        },
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Text(releaseDate, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.contentType.toUpperCase(),
                          style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    overview,
                    style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                          onPressed: () {
                            setState(() {
                              isPlayingVideo = true;
                              _videoController.play();
                            });
                          },
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('Watch Now (Free 480p)', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Recommended Suggestions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.suggestionsList.length,
                itemBuilder: (context, index) {
                  final suggestion = widget.suggestionsList[index];
                  final sPoster = suggestion['poster_path'];
                  final sImageUrl = sPoster != null ? 'https://image.tmdb.org/t/p/w500$sPoster' : '';

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            itemData: suggestion,
                            contentType: widget.contentType,
                            suggestionsList: widget.suggestionsList,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 110,
                      margin: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: sImageUrl.isNotEmpty
                                  ? Image.network(sImageUrl, fit: BoxFit.cover, width: 110)
                                  : Container(color: Colors.grey[900], child: const Icon(Icons.movie)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion['title'] ?? suggestion['name'] ?? 'Suggestion',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore Categories'),
          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Movies'),
              Tab(text: 'TV Shows'),
              Tab(text: 'Anime'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Hollywood Dual Audio (Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('• Bollywood Movies (Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('• South Indian Movies (Hindi Dubbed)', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Web Series Dual Audio (Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('• TV Shows Dual Audio (Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('• Bollywood Series', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Animated Movies (Multi-Audio/Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('• Anime Series (Multi-Audio/Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('• Cartoons (Hindi)', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streamify Premium')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Unlock 1080p, Downloads & Ad-Free Experience',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Free Plan', style: TextStyle(color: Colors.white70)),
                      Text('480p + Ads', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                  Divider(height: 24, color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('VIP Premium', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      Text('1080p + No Ads + Downloads', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {},
                child: const Text('Upgrade Now', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
