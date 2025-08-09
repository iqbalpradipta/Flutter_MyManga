import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manga_bal/src/detail.dart';
import 'package:manga_bal/src/list.dart';
import 'package:manga_bal/src/model/manga_detail.dart';
import 'package:manga_bal/src/network_utils.dart';
import 'package:manga_bal/src/search.dart';
import 'package:manga_bal/src/widget/bottom_nav.dart';

Future<List<MangaSummary>> fetchManga({
  required int page,
  String? genre,
}) async {
  final hasInternet = await NetworkUtils.hasInternetAccess();
  if (!hasInternet) {
    throw Exception('Koneksi internet anda bermasalah !');
  }

  final Map<String, String> queryParams = {
    'page': page.toString(),
    'limit': '30',
  };

  if (genre != null && genre.isNotEmpty && genre != 'Populer') {
    queryParams['genre'] = genre;
  }

  final uri = Uri.parse(
    'https://flutter-my-manga.vercel.app/api/v1/comic',
  ).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final decodedResponse = jsonDecode(response.body);
    final List<dynamic> data = decodedResponse['data'];
    return data.map((json) => MangaSummary.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat daftar manga');
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    MyHome(),
    SearchPage(),
    ListManga(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final List<MangaSummary> _mangaList = [];
  List<MangaSummary> _featuredList = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _genres = [
    'Populer',
    'Action',
    'Adventure',
    'Comedy',
    'Romance',
    'Fantasy',
    'School Life',
    'Horror',
    'Mystery',
    'Drama',
    'Slice of Life',
    'Sports',
    'Supernatural',
    'Psychological',
    'Mecha',
    'Historical',
    'Sci-Fi',
    'Yaoi',
    'Yuri',
    'Ecchi',
    'Harem',
    'Shounen',
    'Shoujo',
    'Seinen',
    'Josei',
  ];
  String _selectedGenre = 'Populer';

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMangaData({bool isRefreshing = false}) async {
    if (_isLoadingMore || (!_hasMoreData && !isRefreshing)) return;

    setState(() {
      if (isRefreshing) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final newManga = await fetchManga(
        page: _currentPage,
        genre: _selectedGenre,
      );

      setState(() {
        if (isRefreshing) {
          _mangaList.clear();
          if (_selectedGenre == 'Populer' && newManga.isNotEmpty) {
            final List<MangaSummary> featured = List<MangaSummary>.from(
              newManga,
            )..shuffle(Random());
            _featuredList = featured.take(5).toList();
          }
        }
        _mangaList.addAll(newManga);
        _currentPage++;
        if (newManga.length < 30) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    _currentPage = 1;
    _hasMoreData = true;
    await _loadMangaData(isRefreshing: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMangaData();
    }
  }

  void _onGenreSelected(String genre) {
    setState(() {
      _selectedGenre = genre;
    });
    _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(),
            Expanded(
              child: _isLoading && _mangaList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!.contains('Koneksi internet anda bermasalah')
                            ? _error!
                            : 'Gagal memuat data: $_error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_featuredList.isNotEmpty)
                                  FeaturedBanner(featuredManga: _featuredList),
                                const SectionHeader(title: 'Genres'),
                                GenreFilterChips(
                                  genres: _genres,
                                  selectedGenre: _selectedGenre,
                                  onGenreSelected: _onGenreSelected,
                                ),
                                const SectionHeader(title: 'Daftar Manga'),
                              ],
                            ),
                          ),
                        ];
                      },
                      body: MangaGrid(
                        mangaList: _mangaList,
                        isLoadingMore: _isLoadingMore,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'MangaBal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({super.key, required this.featuredManga});

  final List<MangaSummary> featuredManga;

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.featuredManga.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (!mounted) return;
      final int nextPage = (_currentPage + 1) % widget.featuredManga.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.featuredManga.isEmpty) {
      return const SizedBox(height: 200);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredManga.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final manga = widget.featuredManga[index];
              return BannerItem(manga: manga);
            },
          ),
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.featuredManga.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.white,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class BannerItem extends StatelessWidget {
  const BannerItem({super.key, required this.manga});

  final MangaSummary manga;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailManga(mangaId: manga.id),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: manga.imageUrl.isNotEmpty
                  ? Image.network(manga.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: const LinearGradient(
                colors: [Colors.black, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          manga.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        manga.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        manga.genres.take(3).join(', '),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class GenreFilterChips extends StatelessWidget {
  const GenreFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  final List<String> genres;
  final String selectedGenre;
  final Function(String) onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) => onGenreSelected(genre),
              selectedColor: Colors.deepPurpleAccent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade300,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: const Color(0xFF252836),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}

class MangaGrid extends StatelessWidget {
  const MangaGrid({
    super.key,
    required this.mangaList,
    required this.isLoadingMore,
  });

  final List<MangaSummary> mangaList;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (mangaList.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Tidak ada manga untuk genre ini.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2 / 3.5,
      ),
      itemCount: mangaList.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == mangaList.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return MangaCard(manga: mangaList[index]);
      },
    );
  }
}

class MangaCard extends StatelessWidget {
  const MangaCard({super.key, required this.manga});

  final MangaSummary manga;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailManga(mangaId: manga.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: manga.imageUrl.isNotEmpty
                  ? Image.network(
                      manga.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.error, color: Colors.grey),
                          ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manga.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            manga.genres.take(2).join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
