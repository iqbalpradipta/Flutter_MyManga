import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_manga/src/model/manga_detail.dart';

class ChapterPage extends StatefulWidget {
  final List<ChapterSummary> allChapters;
  final int initialIndex;

  const ChapterPage({
    super.key,
    required this.allChapters,
    required this.initialIndex,
  });

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Masuk ke mode full screen saat halaman dibuka
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Kembalikan UI ke mode normal saat halaman ditutup
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _navigateToChapter(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.allChapters.length) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ChapterPage(
            allChapters: widget.allChapters,
            initialIndex: newIndex,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = widget.allChapters[_currentIndex];
    final bool hasPrevious = _currentIndex > 0;
    final bool hasNext = _currentIndex < widget.allChapters.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      // Kita sembunyikan AppBar agar lebih imersif
      // Anda bisa menambahkannya kembali jika perlu

      // KEMBALI MENGGUNAKAN LISTVIEW.BUILDER UNTUK SCROLL VERTIKAL
      body: ListView.builder(
        itemCount: currentChapter.pages.length,
        itemBuilder: (context, pageIndex) {
          return Image.network(
            currentChapter.pages[pageIndex],
            // PENTING: fitWidth agar gambar mengisi lebar layar dan tidak terpotong
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Gagal memuat gambar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: !hasPrevious
                  ? null
                  : () => _navigateToChapter(_currentIndex - 1),
              child: const Text('Prev'),
            ),
            Text(
              currentChapter.title.replaceAll('\n', '').trim(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: !hasNext
                  ? null
                  : () => _navigateToChapter(_currentIndex + 1),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
