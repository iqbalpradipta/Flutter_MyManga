import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_manga/src/chapter.dart';
import 'dart:convert';
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
    // Ganti dengan URL API detail Anda
    final response = await http.get(
      Uri.parse('https://api.npoint.io/3178c2ddc4be5b84c2e9/${id-1}'),
    );
    if (response.statusCode == 200) {
      return MangaDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat detail manga');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MangaDetail>(
      future: _mangaDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final manga = snapshot.data!;
          return Scaffold(
            appBar: AppBar(title: Text(manga.title)), // Judul dinamis
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 180,
                        child: Image.network(manga.imageUrl, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gunakan data dari objek 'manga'
                            InfoRow(label: 'Judul', value: ': ${manga.title}'),
                            InfoRow(
                              label: 'Japanese',
                              value: ': ${manga.japaneseTitle}',
                            ),
                            InfoRow(label: 'Skor', value: ': ${manga.score}'),
                            InfoRow(
                              label: 'Produser',
                              value: ': ${manga.producer}',
                            ),
                            InfoRow(label: 'Tipe', value: ': ${manga.type}'),
                            InfoRow(
                              label: 'Status',
                              value: ': ${manga.status}',
                            ),
                            InfoRow(
                              label: 'Total Episode',
                              value: ': ${manga.totalEpisode}',
                            ),
                            InfoRow(
                              label: 'Durasi',
                              value: ': ${manga.duration}',
                            ),
                            InfoRow(
                              label: 'Tanggal Rilis',
                              value: ': ${manga.releaseDate}',
                            ),
                            InfoRow(
                              label: 'Studio',
                              value: ': ${manga.studio}',
                            ),
                            InfoRow(label: 'Genre', value: ': ${manga.genre}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    manga.synopsis, // Gunakan sinopsis dari API
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    color: Colors.blueGrey.shade400,
                    child: Text(
                      '${manga.title} Episode List', // Judul dinamis
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: manga.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = manga.chapters[index];
                      final cleanChapterTitle = chapter.title
                          .replaceAll('\n      ', '')
                          .trim();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            // Teks judul akan mengisi ruang yang tersedia
                            Expanded(
                              child: Text(
                                cleanChapterTitle,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow
                                    .ellipsis, // Jika teks terlalu panjang
                              ),
                            ),

                            // Tombol Baca Chapter
                            ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: Text('Baca $cleanChapterTitle'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChapterPage(
                                      allChapters: manga.chapters,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              // Memberi gaya pada tombol
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.blueGrey.shade700, // Warna tombol
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: Text('Tidak ada data')));
      },
    );
  }
}

// Widget InfoRow tetap sama, tidak perlu diubah
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    // ... isi widget InfoRow ...
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14.0),
          children: <TextSpan>[
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
