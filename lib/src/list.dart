import 'package:flutter/material.dart';
import 'package:my_manga/src/detail.dart';

class ListManga extends StatefulWidget {
  const ListManga({super.key});

  @override
  State<ListManga> createState() => _ListMangaState();
}

class Manga {
  final int id;
  final String title;
  final String imageUrl;

  Manga({required this.id, required this.title, required this.imageUrl});
}

class _ListMangaState extends State<ListManga> {
  final List<Manga> _dummyMangaList = [
    Manga(
      id: 1,
      title: 'Solo Leveling',
      imageUrl:
          'https://cdn1.epicgames.com/spt-assets/91ab4f5ea1a8415184dd4dcbeaf50fc2/solo-levelingarise-1fhh9.jpg',
    ),
    Manga(
      id: 2,
      title: 'One Piece',
      imageUrl:
          'https://m.media-amazon.com/images/M/MV5BODcwNWE3OTMtMDc3MS00NDFjLWE1OTAtNDU3NjgxODMxY2UyXkEyXkFqcGdeQXVyNTAyODkwOQ@@._V1_FMjpg_UX1000_.jpg',
    ),
    Manga(
      id: 3,
      title: 'Jujutsu Kaisen',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtKizVzAPNoqELsDpErVPzlKYP76GXo1iFWQ&s',
    ),
    Manga(
      id: 4,
      title: 'Attack on Titan',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfcZJb-JarS-7Rv6KTrV7eFCQJeX9AqiP0LQ&s',
    ),
    Manga(
      id: 5,
      title: 'Attack on Titan',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfcZJb-JarS-7Rv6KTrV7eFCQJeX9AqiP0LQ&s',
    ),
    Manga(
      id: 6,
      title: 'Attack on Titan',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfcZJb-JarS-7Rv6KTrV7eFCQJeX9AqiP0LQ&s',
    ),
    Manga(
      id: 7,
      title: 'Attack on Titan',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfcZJb-JarS-7Rv6KTrV7eFCQJeX9AqiP0LQ&s',
    ),
    Manga(
      id: 8,
      title: 'Attack on Titan',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfcZJb-JarS-7Rv6KTrV7eFCQJeX9AqiP0LQ&s',
    ),
  ];
  // --- AKHIR DARI DUMMY DATA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Manga")),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2 / 3,
        ),
        itemCount: _dummyMangaList.length,
        itemBuilder: (context, index) {
          final manga = _dummyMangaList[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailManga()),
              );
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ), // Samakan radiusnya
                    image: DecorationImage(
                      image: NetworkImage(
                        manga.imageUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  manga.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
