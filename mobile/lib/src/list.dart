import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_manga/src/detail.dart';

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
  final response = await http.get(Uri.parse('https://api.npoint.io/3178c2ddc4be5b84c2e9/'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => MangaSummary.fromJson(json)).toList();
  } else {
    throw Exception('Gagal memuat daftar manga');
  }
}

class ListManga extends StatefulWidget {
  const ListManga({super.key});

  @override
  State<ListManga> createState() => _ListMangaState();
}

class _ListMangaState extends State<ListManga> {
  late Future<List<MangaSummary>> _mangaFuture;

  @override
  void initState() {
    super.initState();
    _mangaFuture = fetchMangaList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MangaSummary>>(
      future: _mangaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final mangaList = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 2 / 3,
            ),
            itemCount: mangaList.length,
            itemBuilder: (context, index) {
              final manga = mangaList[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailManga(mangaId: manga.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          manga.imageUrl,
                          fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported, color: Colors.grey);
                           },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      manga.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(child: Text('Tidak ada data'));
      },
    );
  }
}