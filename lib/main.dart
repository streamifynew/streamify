import 'dart:convert';
import 'package:flutter/material.dart';
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
      theme: appTheme,
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// THEME
// ============================================================

class AppColors {
  static const bg = Color(0xFF060A14);
  static const heroBgStart = Color(0xFF0D1C3A);
  static const accent = Color(0xFF378ADD);
  static const accentDark = Color(0xFF042C53);
  static const textDim = Color(0x8CFFFFFF); // 55% white
  static const cardBorder = Color(0x14FFFFFF); // 8% white
  static const pillBg = Color(0x14FFFFFF);
  static const pillText = Color(0xBFFFFFFF); // 75% white
}

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.bg,
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,
    surface: AppColors.bg,
  ),
  useMaterial3: true,
);

// ============================================================
// MODEL
// ============================================================
class ContentItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String type; // "movie" or "tv"
  bool hindiDubbed;

  ContentItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    required this.type,
    this.hindiDubbed = false,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json, {String? forcedType}) {
    final type = forcedType ?? json['media_type'] ?? (json['title'] != null ? 'movie' : 'tv');
    return ContentItem(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Untitled',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      type: type,
    );
  }
}

// ============================================================
// TMDB SERVICE
// ============================================================

// ============================================================
// TMDB CONFIG
// Get a free key at https://www.themoviedb.org/settings/api
// Do NOT commit your real key if this repo is public — load it
// from --dart-define or a local untracked config file instead.
// ============================================================
const String tmdbApiKey = "368c97ebade673670d0a9c28b6facb17";
const String tmdbBase = "https://api.themoviedb.org/3";
const String imgBase = "https://image.tmdb.org/t/p";

String posterUrl(String? path, {String size = "w342"}) {
  if (path == null || path.isEmpty) return "";
  return "$imgBase/$size$path";
}

// ------------------------------------------------------------
// CATEGORY -> SUBCATEGORY MAP (matches the app's category rows)
// ------------------------------------------------------------
const Map<String, List<List<String>>> subcats = {
  "movies": [
    ["hollywood", "Hollywood multi-audio"],
    ["bollywood", "Bollywood Hindi"],
    ["south", "South cinema multi-audio"],
  ],
  "tvshows": [
    ["webseries", "Webseries multi-audio"],
    ["tvshows", "TV shows multi-audio"],
    ["kdrama", "K-drama multi-audio"],
  ],
  "anime": [
    ["animated", "Animated movies/shows"],
    ["anime", "Anime"],
    ["cartoon", "Cartoon shows/series"],
  ],
};

class TmdbService {
  Uri _discoverUrl(String type, Map<String, String> params) {
    return Uri.parse("$tmdbBase/discover/$type").replace(queryParameters: {
      "api_key": tmdbApiKey,
      "sort_by": "popularity.desc",
      ...params,
    });
  }

  Future<List<ContentItem>> fetchTrending() async {
    final res = await http.get(Uri.parse("$tmdbBase/trending/all/week?api_key=$tmdbApiKey"));
    final data = jsonDecode(res.body);
    return (data['results'] as List)
        .map((r) => ContentItem.fromJson(r))
        .toList();
  }

  Future<List<ContentItem>> fetchMovies(String? sub) async {
    if (sub == "south") {
      // Telugu/Tamil/Malayalam/Kannada, merged, kept only if a Hindi dub exists.
      final langs = ["te", "ta", "ml", "kn"];
      final Map<int, ContentItem> merged = {};
      for (final lang in langs) {
        final res = await http.get(_discoverUrl("movie", {"with_original_language": lang}));
        final data = jsonDecode(res.body);
        for (final r in data['results']) {
          final item = ContentItem.fromJson(r, forcedType: "movie");
          merged[item.id] = item;
        }
      }
      final list = merged.values.toList();
      for (final item in list) {
        item.hindiDubbed = await hasHindiDub(item.id, "movie");
      }
      return list.where((i) => i.hindiDubbed).toList();
    }

    final lang = sub == "bollywood" ? "hi" : "en"; // hollywood default
    final res = await http.get(_discoverUrl("movie", {"with_original_language": lang}));
    final data = jsonDecode(res.body);
    return (data['results'] as List)
        .map((r) => ContentItem.fromJson(r, forcedType: "movie"))
        .toList();
  }

  Future<List<ContentItem>> fetchTV(String? sub) async {
    Uri url;
    if (sub == "kdrama") {
      url = _discoverUrl("tv", {"with_origin_country": "KR"});
    } else if (sub == "webseries") {
      url = _discoverUrl("tv", {"with_original_language": "en"});
    } else {
      url = _discoverUrl("tv", {});
    }
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return (data['results'] as List)
        .map((r) => ContentItem.fromJson(r, forcedType: "tv"))
        .toList();
  }

  Future<List<ContentItem>> fetchAnime(String? sub) async {
    Uri url;
    String type;
    if (sub == "anime") {
      url = _discoverUrl("tv", {"with_genres": "16", "with_original_language": "ja"});
      type = "tv";
    } else if (sub == "cartoon") {
      url = _discoverUrl("tv", {"with_genres": "16", "with_original_language": "en"});
      type = "tv";
    } else {
      url = _discoverUrl("movie", {"with_genres": "16"}); // animated movies/shows
      type = "movie";
    }
    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return (data['results'] as List)
        .map((r) => ContentItem.fromJson(r, forcedType: type))
        .toList();
  }

  Future<List<ContentItem>> fetchByCategory(String cat, [String? sub]) async {
    switch (cat) {
      case "trending":
        return fetchTrending();
      case "movies":
        return fetchMovies(sub);
      case "tvshows":
        return fetchTV(sub);
      case "anime":
        return fetchAnime(sub);
      default:
        return [];
    }
  }

  // ------------------------------------------------------------
  // HINDI-DUB HEURISTIC
  // TMDB doesn't expose dubbed-audio info directly. This checks
  // whether a Hindi (hi) translation exists for the title as a
  // rough proxy. For accurate badges, prefer a flag from your own
  // content DB once you're bulk-uploading (hindiDubbed: true/false).
  // ------------------------------------------------------------
  Future<bool> hasHindiDub(int id, String type) async {
    try {
      final res = await http.get(
        Uri.parse("$tmdbBase/$type/$id/translations?api_key=$tmdbApiKey"),
      );
      final data = jsonDecode(res.body);
      final translations = data['translations'] as List? ?? [];
      return translations.any((t) => t['iso_639_1'] == "hi");
    } catch (e) {
      return false;
    }
  }

  Future<void> tagHindi(List<ContentItem> items, {int limit = 10}) async {
    final slice = items.take(limit).toList();
    await Future.wait(slice.map((item) async {
      item.hindiDubbed = await hasHindiDub(item.id, item.type);
    }));
  }

  Future<Map<String, dynamic>> fetchDetails(int id, String type) async {
    final res = await http.get(Uri.parse(
        "$tmdbBase/$type/$id?api_key=$tmdbApiKey&append_to_response=credits"));
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> fetchSeasonEpisodes(int id, int seasonNumber) async {
    final res = await http.get(Uri.parse(
        "$tmdbBase/tv/$id/season/$seasonNumber?api_key=$tmdbApiKey"));
    final data = jsonDecode(res.body);
    return data['episodes'] ?? [];
  }

  // ------------------------------------------------------------
  // VIDEO SOURCE HOOK
  // TMDB has no playable video files — it's metadata only.
  // When you bulk-upload your own hosted content, store each
  // video keyed by its TMDB id (and type) in Firestore/your DB.
  // Wire that lookup here so Play knows what to stream.
  // ------------------------------------------------------------
  Future<String?> getVideoUrl(int tmdbId, String type) async {
    // TODO: replace with your real Firestore lookup, e.g.
    // final doc = await FirebaseFirestore.instance
    //     .collection('videos').doc('${type}_$tmdbId').get();
    // return doc.exists ? doc['videoUrl'] as String : null;
    return null;
  }
}

// ============================================================
// POSTER CARD WIDGET
// ============================================================

class PosterCard extends StatelessWidget {
  final ContentItem item;
  final double width;
  final double height;

  const PosterCard({
    super.key,
    required this.item,
    this.width = 110,
    this.height = 155,
  });

  @override
  Widget build(BuildContext context) {
    final poster = posterUrl(item.posterPath);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(id: item.id, type: item.type),
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF12203F),
          image: poster.isNotEmpty
              ? DecorationImage(image: NetworkImage(poster), fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            // bottom gradient for legible title
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                    stops: [0.15, 0.55],
                  ),
                ),
              ),
            ),
            if (item.hindiDubbed)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Hindi",
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            Positioned(
              bottom: 6,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.voteAverage > 0)
                    Text(
                      item.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(color: Color(0xFF85B7EB), fontSize: 10),
                    ),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
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

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final tmdb = TmdbService();
  String activeTab = "trending";
  bool loading = true;
  ContentItem? heroItem;

  // cat "trending" -> single list; others -> map of sub key -> list
  List<ContentItem> trendingItems = [];
  Map<String, List<ContentItem>> subLists = {};

  final tabs = const [
    ["trending", "Trending"],
    ["movies", "Movies"],
    ["tvshows", "TV shows"],
    ["anime", "Anime"],
  ];

  @override
  void initState() {
    super.initState();
    _load("trending");
  }

  Future<void> _load(String cat) async {
    setState(() {
      loading = true;
      activeTab = cat;
    });

    if (cat == "trending") {
      final items = await tmdb.fetchTrending();
      await tmdb.tagHindi(items);
      setState(() {
        trendingItems = items;
        heroItem = items.isNotEmpty ? items.first : null;
        loading = false;
      });
      return;
    }

    final subs = subcats[cat] ?? [];
    final Map<String, List<ContentItem>> result = {};
    for (final s in subs) {
      final items = await tmdb.fetchByCategory(cat, s[0]);
      await tmdb.tagHindi(items);
      result[s[0]] = items;
    }
    setState(() {
      subLists = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => _load(activeTab),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHero(),
              _buildTabs(),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                )
              else
                _buildRows(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHero() {
    final backdrop = heroItem != null ? posterUrl(heroItem!.backdropPath, size: "w780") : "";
    return Container(
      height: MediaQuery.of(context).size.height * 0.42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.heroBgStart, AppColors.bg],
        ),
        image: backdrop.isNotEmpty
            ? DecorationImage(image: NetworkImage(backdrop), fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), AppColors.bg],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Streamify",
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 19)),
                  Icon(Icons.search, color: Colors.white),
                ],
              ),
            ),
          ),
          if (heroItem != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(heroItem!.title,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    heroItem!.voteAverage > 0 ? "${heroItem!.voteAverage.toStringAsFixed(1)} rating" : "",
                    style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.accentDark,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailsScreen(id: heroItem!.id, type: heroItem!.type, autoplay: true),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text("Play"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.12),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailsScreen(id: heroItem!.id, type: heroItem!.type),
                          ),
                        ),
                        child: const Text("More info"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: tabs.map((t) {
          final isActive = activeTab == t[0];
          return GestureDetector(
            onTap: () => _load(t[0]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.pillBg,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                t[1],
                style: TextStyle(
                  color: isActive ? AppColors.accentDark : AppColors.pillText,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRows() {
    if (activeTab == "trending") {
      return _sectionRow("Trending now", trendingItems, "trending", null);
    }
    final subs = subcats[activeTab] ?? [];
    return Column(
      children: subs
          .map((s) => _sectionRow(s[1], subLists[s[0]] ?? [], activeTab, s[0]))
          .toList(),
    );
  }

  Widget _sectionRow(String title, List<ContentItem> items, String cat, String? sub) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoryScreen(category: cat, subcategory: sub)),
                  ),
                  child: const Text("See all", style: TextStyle(color: AppColors.accent, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 155,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: items.map((i) => PosterCard(item: i)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: AppColors.accent),
          Icon(Icons.search, color: Colors.white54),
          Icon(Icons.download, color: Colors.white54),
          Icon(Icons.person, color: Colors.white54),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORY SCREEN
// ============================================================

class CategoryScreen extends StatefulWidget {
  final String category;
  final String? subcategory;

  const CategoryScreen({super.key, required this.category, this.subcategory});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final tmdb = TmdbService();
  bool loading = true;
  List<ContentItem> items = [];
  String? activeSub;

  static const titles = {
    "trending": "Trending",
    "movies": "Movies",
    "tvshows": "TV shows",
    "anime": "Anime",
  };

  @override
  void initState() {
    super.initState();
    activeSub = widget.subcategory ?? (subcats[widget.category]?.first[0]);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final result = await tmdb.fetchByCategory(widget.category, activeSub);
    await tmdb.tagHindi(result, limit: 20);
    setState(() {
      items = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subs = subcats[widget.category];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(titles[widget.category] ?? "Browse"),
      ),
      body: Column(
        children: [
          if (subs != null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: subs.map((s) {
                  final isActive = activeSub == s[0];
                  return GestureDetector(
                    onTap: () {
                      setState(() => activeSub = s[0]);
                      _load();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accent.withOpacity(0.25) : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s[1],
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : items.isEmpty
                    ? const Center(
                        child: Text("No content found.", style: TextStyle(color: AppColors.textDim)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => PosterCard(
                          item: items[i],
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DETAILS SCREEN
// ============================================================

class DetailsScreen extends StatefulWidget {
  final int id;
  final String type; // "movie" | "tv"
  final bool autoplay;

  const DetailsScreen({super.key, required this.id, required this.type, this.autoplay = false});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final tmdb = TmdbService();
  Map<String, dynamic>? details;
  bool isHindi = false;
  List<dynamic> episodes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await tmdb.fetchDetails(widget.id, widget.type);
    final hindi = await tmdb.hasHindiDub(widget.id, widget.type);

    List<dynamic> eps = [];
    if (widget.type == "tv" && data['seasons'] != null && (data['seasons'] as List).isNotEmpty) {
      final seasons = data['seasons'] as List;
      final firstReal = seasons.firstWhere((s) => s['season_number'] > 0, orElse: () => seasons.first);
      eps = await tmdb.fetchSeasonEpisodes(widget.id, firstReal['season_number']);
    }

    setState(() {
      details = data;
      isHindi = hindi;
      episodes = eps;
      loading = false;
    });

    if (widget.autoplay) _play();
  }

  Future<void> _play() async {
    final url = await tmdb.getVideoUrl(widget.id, widget.type);
    if (url == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No video linked for this title yet.")),
        );
      }
      return;
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerScreen(videoUrl: url, title: details?['title'] ?? details?['name'] ?? ""),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || details == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    final d = details!;
    final title = d['title'] ?? d['name'] ?? "Untitled";
    final backdrop = posterUrl(d['backdrop_path'], size: "w780");
    final year = (d['release_date'] ?? d['first_air_date'] ?? "").toString();
    final genre = (d['genres'] as List?)?.isNotEmpty == true ? d['genres'][0]['name'] : null;
    final runtime = d['runtime'] != null
        ? "${d['runtime']} min"
        : ((d['episode_run_time'] as List?)?.isNotEmpty == true ? "${d['episode_run_time'][0]} min/ep" : null);
    final rating = d['vote_average'] != null ? (d['vote_average'] as num).toStringAsFixed(1) : null;
    final cast = ((d['credits']?['cast'] ?? []) as List).take(8).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.42,
                decoration: BoxDecoration(
                  color: const Color(0xFF12203F),
                  image: backdrop.isNotEmpty
                      ? DecorationImage(image: NetworkImage(backdrop), fit: BoxFit.cover)
                      : null,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.1), AppColors.bg],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  [genre, year.length >= 4 ? year.substring(0, 4) : null, runtime, rating != null ? "$rating rating" : null]
                      .where((e) => e != null && e.isNotEmpty)
                      .join(" · "),
                  style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isHindi) _pill("Hindi", accent: true),
                    _pill("English"),
                    _pill("720p"),
                    _pill("1080p"),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.accentDark,
                      ),
                      onPressed: _play,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text("Play"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Watchlist"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  d['overview']?.isNotEmpty == true ? d['overview'] : "No description available.",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.6),
                ),
                if (cast.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text("Cast", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: cast.map<Widget>((c) {
                        final img = posterUrl(c['profile_path'], size: "w185");
                        return Container(
                          width: 64,
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF12203F),
                                backgroundImage: img.isNotEmpty ? NetworkImage(img) : null,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c['name'] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white60, fontSize: 10),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                if (episodes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text("Episodes", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...episodes.asMap().entries.map((e) {
                    final i = e.key;
                    final ep = e.value;
                    final thumb = posterUrl(ep['still_path'], size: "w300");
                    final playing = i == 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: playing ? AppColors.accent.withOpacity(0.12) : null,
                        border: playing ? Border.all(color: AppColors.accent.withOpacity(0.3), width: 0.5) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF12203F),
                              borderRadius: BorderRadius.circular(6),
                              image: thumb.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(thumb), fit: BoxFit.cover)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Episode ${ep['episode_number']}: ${ep['name']}",
                                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                                Text(
                                  playing ? "Now playing" : (ep['runtime'] != null ? "${ep['runtime']} min" : ""),
                                  style: TextStyle(
                                      color: playing ? const Color(0xFF85B7EB) : Colors.white38, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: accent ? AppColors.accent : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent ? AppColors.accentDark : Colors.white70,
          fontSize: 11,
          fontWeight: accent ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

// ============================================================
// PLAYER SCREEN
// ============================================================

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const PlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: ready
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (ready)
              VideoProgressIndicator(_controller, allowScrubbing: true,
                  colors: const VideoProgressColors(playedColor: AppColors.accent)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
