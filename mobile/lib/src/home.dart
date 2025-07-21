import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_manga/src/list.dart';
import 'package:my_manga/src/widget/bottom_nav.dart';

// Model data yang sesuai dengan API Anda
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

// Fungsi untuk mengambil daftar manga dari API
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

// Halaman utama yang mengelola state navigasi
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  // Daftar halaman/widget untuk setiap tab
  static final List<Widget> _widgetOptions = <Widget>[
    const MyHome(), // Halaman Home yang sudah didesain ulang
    const Center(child: Text('Halaman Search')), // Placeholder
    const ListManga(), // Halaman List Manga Anda
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman yang sesuai dengan tab yang dipilih
      body: _widgetOptions.elementAt(_selectedIndex),
      // Bottom Navigation Bar Anda tetap di sini
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- INI ADALAH DESAIN BARU UNTUK HALAMAN HOME ANDA ---
// Diubah menjadi StatefulWidget untuk mengambil data dari API
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
      appBar: AppBar(
        title: const Text(
          'MangaKu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Gunakan FutureBuilder untuk menampilkan data dari API
      body: FutureBuilder<List<MangaSummary>>(
        future: _mangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final mangaList = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FeaturedMangaBanner(),
                  MangaCarouselSection(
                    title: 'Populer Minggu Ini',
                    mangaList: mangaList,
                  ),
                  MangaCarouselSection(
                    title: 'Baru Rilis',
                    mangaList: mangaList.reversed.toList(),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Tidak ada manga.'));
        },
      ),
    );
  }
}

// Widget reusable untuk setiap baris carousel
class MangaCarouselSection extends StatelessWidget {
  final String title;
  final List<MangaSummary> mangaList;

  const MangaCarouselSection({
    super.key,
    required this.title,
    required this.mangaList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220, // Tinggi untuk carousel
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: mangaList.length,
            itemBuilder: (context, index) {
              final manga = mangaList[index];
              return MangaCard(manga: manga);
            },
          ),
        ),
      ],
    );
  }
}

// Widget untuk kartu manga di dalam carousel
class MangaCard extends StatelessWidget {
  final MangaSummary manga;
  const MangaCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                manga.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk banner utama di atas
class FeaturedMangaBanner extends StatelessWidget {
  const FeaturedMangaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            'https://cdn1.epicgames.com/spt-assets/91ab4f5ea1a8415184dd4dcbeaf50fc2/solo-levelingarise-1fhh9.jpg',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black, Colors.transparent],
          ),
        ),
        child: const Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manga of the Week',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
