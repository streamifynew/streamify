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
            // 1. Top Bar: App Logo / Icon & Search Bar
            _buildTopBar(),

            // 2. Horizontal Navigation Tabs
            _buildTabBar(),

            // 3. Main Scrollable Content Area (Structured & Clean)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Banner Carousel Section
                    _buildFeaturedBanner(),

                    // Sub-Categories Filter Pills
                    _buildSubCategoryPills(),
                    const SizedBox(height: 15),

                    // Section 1: Trending Movies / One-Person Army Action
                    _buildSectionHeader('One-Person Army Action 👊'),
                    _buildHorizontalCardList([
                      _ContentItem('Irumudi [Hindi]', 'Hindi', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300&auto=format&fit=crop&q=60'),
                      _ContentItem('Kattalan [Hindi]', 'Hindi', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=300&auto=format&fit=crop&q=60'),
                      _ContentItem('Mirzapur: The Movie', 'Hindi', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=300&auto=format&fit=crop&q=60'),
                    ]),

                    // Section 2: Laugh Out Loud
                    _buildSectionHeader('Laugh Out Loud 😂'),
                    _buildHorizontalCardList([
                      _ContentItem('Vibe [Hindi]', 'Hindi', 'https://images.unsplash.com/photo-1563089145-599997674d42?w=300&auto=format&fit=crop&q=60'),
                      _ContentItem('Modha Rathiri [Hindi]', 'Hindi', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300&auto=format&fit=crop&q=60'),
                      _ContentItem('Dhamaal 4 [Hindi]', 'Hindi', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=300&auto=format&fit=crop&q=60'),
                    ]),

                    // Section 3: Indian Stars Row
                    _buildSectionHeader('Indian Stars'),
                    _buildActorList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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

  Widget _buildTopBar() {
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
            onTap: () => setState(() => _selectedTab = tab),
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

  Widget _buildFeaturedBanner() {
    return Container(
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
                    Text('2026 • Action / Animation', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryPills() {
    final pills = ['All', 'Action', 'Romance', 'Comedy', 'South Indian'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: pills.map((pill) {
          final isSelected = pill == 'All';
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green[800] : const Color(0xFF2A2A2A),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'All >',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCardList(List<_ContentItem> items) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        height: 150,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.badge,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActorList() {
    final actors = [
      {'name': 'Allu Arjun', 'img': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=60'},
      {'name': 'Kareena Kapoor', 'img': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=60'},
      {'name': 'Shah Rukh Khan', 'img': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=60'},
      {'name': 'Kriti Sanon', 'img': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=60'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Container(
            width: 75,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(actor['img']!),
                ),
                const SizedBox(height: 4),
                Text(
                  actor['name']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContentItem {
  final String title;
  final String badge;
  final String imageUrl;

  _ContentItem(this.title, this.badge, this.imageUrl);
}
