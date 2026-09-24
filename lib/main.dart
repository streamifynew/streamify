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
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.greenAccent,
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}

// 1. HOME SCREEN (index.html equivalent)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedTab = 'Movie';

  final List<String> _tabs = [
    'Trending',
    'Movie',
    'TV',
    'TV Channel',
    'Cricket',
    'Anime',
    'ShortTV',
    'Football'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar & Search Bar
            _buildTopBar(context),

            // Horizontal Category Tabs
            _buildTabBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeaturedBanner(context),
                    _buildSubCategoryPills(context),
                    const SizedBox(height: 15),
                    _buildSectionHeader('Trending Movies', context),
                    _buildHorizontalCardList(context),
                    _buildSectionHeader('Laugh Out Loud', context),
                    _buildHorizontalCardList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            // Example navigation or handling
          }
        },
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: 'Downloads'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.greenAccent]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search movies, TV shows...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[700],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = tab);
              // Navigate to Category Screen if clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen(categoryName: tab)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=60'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Moana [Hindi]',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.play_circle, color: Colors.greenAccent, size: 16),
                      SizedBox(width: 4),
                      Text('2026 • Action', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryPills(BuildContext context) {
    final pills = ['All', 'Action', 'Romance', 'Comedy', 'South Indian'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: pills.map((pill) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: pill == 'All' ? Colors.green[800] : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pill,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen(categoryName: title)),
              );
            },
            child: const Text('All >', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCardList(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailsScreen()),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300&auto=format&fit=crop&q=60',
                      height: 150,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Irumudi [Hindi]',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 2. CATEGORY SCREEN (category.html equivalent)
class CategoryScreen extends StatelessWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailsScreen()),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1563089145-599997674d42?w=300&auto=format&fit=crop&q=60',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Movie Title',
                  maxLines: 1,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 3. DETAILS SCREEN (details.html equivalent)
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=600&auto=format&fit=crop&q=60',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: FloatingActionButton(
                    backgroundColor: Colors.greenAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PlayerScreen()),
                      );
                    },
                    child: const Icon(Icons.play_arrow, color: Colors.black, size: 35),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Movie Details / Title',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2026 • Action • Hindi • 2h 15m',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Description of the movie or show goes here. Complete details fetched from TMDB integration logic.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. PLAYER SCREEN (player.html equivalent)
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_circle_fill, size: 80, color: Colors.greenAccent),
                SizedBox(height: 10),
                Text(
                  'Streaming Video Player...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
