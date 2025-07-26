import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:manga_bal/src/list.dart';
import 'package:manga_bal/src/search.dart';
import 'package:manga_bal/src/widget/bottom_nav.dart';
import 'package:manga_bal/src/detail.dart';

class MangaSummary {
  final int id;
  final String title;
  final String imageUrl;

  MangaSummary({required this.id, required this.title, required this.imageUrl});

  factory MangaSummary.fromJson(Map<String, dynamic> json) {
    return MangaSummary(
      id: json['id'],
      title: json['title'],
      imageUrl: json['comic_image'],
    );
  }
}

Future<List<MangaSummary>> fetchMangaList() async {
  final response = await http.get(
    Uri.parse('https://api.npoint.io/3178c2ddc4be5b84c2e9/'),
  );
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
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
  late Future<List<MangaSummary>> _mangaFuture;

  @override
  void initState() {
    super.initState();
    _mangaFuture = fetchMangaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: SafeArea(
        child: FutureBuilder<List<MangaSummary>>(
          future: _mangaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat data: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else if (snapshot.hasData) {
              final mangaList = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomHeader(),
                    SectionHeader(
                      title: 'Recommendation Read',
                      onSeeAll: () {},
                    ),
                    RecommendationReadCarousel(mangaList: mangaList),
                    SectionHeader(title: 'Suggested Manga', onSeeAll: () {}),
                    SuggestedMangaGrid(mangaList: mangaList),
                  ],
                ),
              );
            }
            return const Center(
              child: Text(
                'Tidak ada manga.',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MangaBal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Selamat Datang di MangaBal",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionHeader({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All >',
              style: TextStyle(color: Colors.deepPurple.shade300),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationReadCarousel extends StatefulWidget {
  final List<MangaSummary> mangaList;
  const RecommendationReadCarousel({super.key, required this.mangaList});

  @override
  State<RecommendationReadCarousel> createState() =>
      _RecommendationReadCarouselState();
}

class _RecommendationReadCarouselState
    extends State<RecommendationReadCarousel> {
  List<MangaSummary> shuffledList = [];

  @override
  void initState() {
    super.initState();
    shuffledList = List<MangaSummary>.from(widget.mangaList)..shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: shuffledList.length,
        itemBuilder: (context, index) {
          return MangaCard(manga: shuffledList[index]);
        },
      ),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailManga(mangaId: manga.id),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  manga.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.grey),
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
          ],
        ),
      ),
    );
  }
}

class SuggestedMangaGrid extends StatelessWidget {
  final List<MangaSummary> mangaList;
  const SuggestedMangaGrid({super.key, required this.mangaList});

  @override
  Widget build(BuildContext context) {
    final suggestedItems = mangaList.reversed.take(4).toList();

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
      itemCount: suggestedItems.length,
      itemBuilder: (context, index) {
        return MangaCard(manga: suggestedItems[index]);
      },
    );
  }
}
