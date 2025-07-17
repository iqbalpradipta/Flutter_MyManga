import 'package:flutter/material.dart';

class DetailManga extends StatefulWidget {
  const DetailManga({super.key});

  @override
  State<DetailManga> createState() => _DetailMangaState();
}

class _DetailMangaState extends State<DetailManga> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manga Detail')),
      body: Text('Welcome Detail'),
    );
  }
}