import 'package:flutter/material.dart';
import 'package:my_manga/src/chapter.dart';

class DetailManga extends StatelessWidget {
  const DetailManga({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baca Solo Leveling Sub Indo')),
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
                  child: Image.network(
                    'https://cdn1.epicgames.com/spt-assets/91ab4f5ea1a8415184dd4dcbeaf50fc2/solo-levelingarise-1fhh9.jpg', // Ganti dengan URL gambar sebenarnya
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      InfoRow(label: 'Judul', value: ': Solo Leveling'),
                      InfoRow(label: 'Japanese', value: ': 俺だけレベルアップな件'),
                      InfoRow(label: 'Skor', value: ': 8.29'),
                      InfoRow(
                        label: 'Produser',
                        value: ': ANIPLEX, Crunchyroll...',
                      ),
                      InfoRow(label: 'Tipe', value: ': TV'),
                      InfoRow(label: 'Status', value: ': Completed'),
                      InfoRow(label: 'Total Episode', value: ': 12'),
                      InfoRow(label: 'Durasi', value: ': 23 Menit'),
                      InfoRow(label: 'Tanggal Rilis', value: ': Jan 07, 2024'),
                      InfoRow(label: 'Studio', value: ': A-1 Pictures'),
                      InfoRow(
                        label: 'Genre',
                        value: ': Action, Adventure, Fantasy',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            const Text(
              'Dunia diserang monster! Muncullah "hunter" untuk menyerang monster-monster itu. Di kalangan hunter, ada yang disebut hunter terlemah di dunia. Itulah julukan Seong Jin-woo. Masuk rumah sakit adalah kebiasaannya setelah masuk ke dungeon. Suatu hari, saat melakukan raid, suatu peristiwa tragis menimpanya. Peristiwa itu hampir merenggut nyawanya. Namun, saat tersadar, dia mendapati dirinya masih hidup dan melihat sesuatu yang tidak bisa dilihat orang lain. Sejak saat itu, kehidupan Seong Jin-woo berubah. Inilah perjalanan Seong Jin-woo untuk menjadi hunter terkuat di dunia!',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              color: Colors.blueGrey.shade400,
              child: const Text(
                'Solo Leveling Episode List (Link Download Episode + Streaming)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap:
                  true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: 12,
              itemBuilder: (context, index) {
                final episodeNumber = 12 - index; 
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chapter $episodeNumber Sub Indo',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                      TextButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text('Baca Chapter $episodeNumber'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Chapter(chapterNumber: episodeNumber),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
