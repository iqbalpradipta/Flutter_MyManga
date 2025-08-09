import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:manga_bal/src/list.dart';
import 'package:manga_bal/src/model/manga_detail.dart';
import 'package:manga_bal/src/search.dart';
import 'package:manga_bal/src/widget/bottom_nav.dart';

import 'package:manga_bal/src/detail.dart';

import 'package:manga_bal/src/widget/custom_app_bar.dart';

import 'package:manga_bal/src/widget/featured_banner.dart';
import 'package:manga_bal/src/widget/section_header.dart';

Future<List<MangaSummary>> fetchManga({
  required int page,
  String? genre,
}) async {
  final Map<String, String> queryParams = {
    'page': page.toString(),
    'limit': '30',
  };

  if (genre != null && genre.isNotEmpty && genre != 'Populer') {
    queryParams['genre'] = genre;
  }

  final uri = Uri.parse('https://flutter-my-manga.vercel.app/api/v1/comic')
      .replace(queryParameters: queryParams);
  
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
    setState(() { _selectedIndex = index; });
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
  
  final List<String> _genres = ['Populer', 'Action', 'Comedy', 'Romance', 'Fantasy', 'School Life'];
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
             List<MangaSummary> featured = List<MangaSummary>.from(newManga)..shuffle(Random());
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
      setState(() { _error = e.toString(); });
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
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
                      ? Center(child: Text('Gagal memuat data: $_error', style: const TextStyle(color: Colors.white)))
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
                                    const SectionHeader(title: 'Category'),
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




class GenreFilterChips extends StatelessWidget {
  final List<String> genres;
  final String selectedGenre;
  final Function(String) onGenreSelected;

  const GenreFilterChips({
    super.key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

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
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade300, fontWeight: FontWeight.bold),
              backgroundColor: const Color(0xFF252836),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }
}

class MangaGrid extends StatelessWidget {
  final List<MangaSummary> mangaList;
  final bool isLoadingMore;
  const MangaGrid({super.key, required this.mangaList, required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    if (mangaList.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Tidak ada manga untuk genre ini.', style: TextStyle(color: Colors.grey)),
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
  final MangaSummary manga;
  const MangaCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailManga(mangaId: manga.id)));
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
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error, color: Colors.grey)),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Text(manga.genres.take(2).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
