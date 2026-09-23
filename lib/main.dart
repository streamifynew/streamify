import 'package:flutter/material.dart';

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
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Banner
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Text(
                      'Trending Now: Blockbuster Movie',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildMovieRow(context, 'Trending Movies'),
            _buildMovieRow(context, 'Latest Web Series'),
            _buildMovieRow(context, 'Action & Thriller'),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieRow(BuildContext context, String categoryTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              categoryTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Movie click hone par Detail Screen par jayenge
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(movieTitle: '$categoryTitle - Movie ${index + 1}'),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.movie, size: 40, color: Colors.redAccent),
                        const SizedBox(height: 10),
                        Text(
                          'Movie ${index + 1}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
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

// Detail Screen jahan movie ki info aur Play button hoga
class DetailScreen extends StatelessWidget {
  final String movieTitle;
  const DetailScreen({super.key, required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_filled, size: 80, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              movieTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Description: Yeh ek shandar movie hai jo Streamify par available hai. High quality streaming ka maza lijiye.',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ).wrap(
                ElevatedButton(
                  onPressed: () {
                    // Yahan video player open hoga
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playing video...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Play Movie', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
