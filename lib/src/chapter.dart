import 'package:flutter/material.dart';

class Chapter extends StatelessWidget {
  const Chapter({super.key, required int chapterNumber});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manga Solo Leveling')),
      body: Center(
        child: Text('Hello Chapter'),
      ),
    );
  }
}