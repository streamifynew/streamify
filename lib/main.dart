import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Banner
                  Container(
                    height: 220,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: trendingMovies.isNotEmpty && trendingMovies[0]['backdrop_path'] != null
                          ? DecorationImage(
                              image: NetworkImage(
                                  'https://image.tmdb.org/t/p/w500${trendingMovies[0]['backdrop_path']}'),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: const LinearGradient(
                        colors: [Colors.redAccent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        trendingMovies.isNotEmpty ? trendingMovies[0]['title'] ?? 'Blockbuster' : 'Featured Movie',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _buildSectionRow(context, 'Hollywood Dual Audio (Hindi)', trendingMovies),
                  _buildSectionRow(context, 'Bollywood & South Movies', trendingMovies.reversed.toList()),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionRow(BuildContext context, String title, List movies) {
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

                return Container(
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
                        movie['title'] ?? 'Unknown',
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
                );
              },
            ),
          ),
        ],
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
