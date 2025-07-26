import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

import 'package:my_manga/src/chapter.dart';
import 'package:my_manga/src/model/manga_detail.dart';

class DetailManga extends StatefulWidget {
  final int mangaId;
  const DetailManga({super.key, required this.mangaId});

  @override
  State<DetailManga> createState() => _DetailMangaState();
}

class _DetailMangaState extends State<DetailManga> {
  late Future<MangaDetail> _mangaDetailFuture;

  @override
  void initState() {
    super.initState();
    _mangaDetailFuture = fetchMangaDetail(widget.mangaId);
  }

  Future<MangaDetail> fetchMangaDetail(int id) async {
    final response = await http.get(
      Uri.parse('https://api.npoint.io/3178c2ddc4be5b84c2e9/${id - 1}'),
    );
    if (response.statusCode == 200) {
      return MangaDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail manga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: FutureBuilder<MangaDetail>(
        future: _mangaDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (snapshot.hasData) {
            final manga = snapshot.data!;
            return MangaDetailBody(manga: manga);
          }
          return const Center(
            child: Text(
              "Tidak ada data.",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class MangaDetailBody extends StatelessWidget {
  final MangaDetail manga;
  const MangaDetailBody({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              manga.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade800),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: const Color(0xFF1F1D2B)),
            ),
          ),

          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.only(
                        top:
                            kToolbarHeight + MediaQuery.of(context).padding.top,
                      ),
                      child: MangaInfoHeader(manga: manga),
                    ),
                  ),
                  expandedHeight: 320,
                  pinned: false,
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      indicatorColor: Colors.deepPurpleAccent,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Chapters'),
                        Tab(text: 'Details'),
                        Tab(text: 'Similar'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                ChapterList(
                  chapters: manga.chapters,
                  allChapters: manga.chapters,
                ),
                const Center(
                  child: Text(
                    'Detail Info Here',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const Center(
                  child: Text(
                    'Similar Manga Here',
                    style: TextStyle(color: Colors.white),
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

class MangaInfoHeader extends StatelessWidget {
  final MangaDetail manga;
  const MangaInfoHeader({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              manga.imageUrl,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manga.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By Horikoshi Kōhei',
                  style: TextStyle(color: Colors.grey.shade300),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ongoing',
                  style: TextStyle(
                    color: Colors.yellow.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '8.3',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.favorite, color: Colors.pink, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '65k',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

class ChapterList extends StatelessWidget {
  final List<ChapterSummary> chapters;
  final List<ChapterSummary> allChapters;
  const ChapterList({
    super.key,
    required this.chapters,
    required this.allChapters,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final cleanChapterTitle = chapter.title.replaceAll('\n', '').trim();
        final chapterNumber = cleanChapterTitle.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  cleanChapterTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterPage(
                        allChapters: allChapters,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 16),
                label: Text('Baca Chapter $chapterNumber'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.transparent, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
