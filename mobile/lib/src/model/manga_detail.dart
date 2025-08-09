class MangaDetail {

  MangaDetail({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.rating,
    required this.chapters,
    required this.author,
    required this.status,
    required this.released,
    required this.genres,
  });

  factory MangaDetail.fromJson(Map<String, dynamic> json) {
    final chaptersList = json['chapters'] as List? ?? [];
    final List<ChapterSummary> chapters = chaptersList.map((c) => ChapterSummary.fromJson(c)).toList();
    
    final genresList = json['genres'] as List? ?? [];
    final List<String> genres = genresList.cast<String>();

    return MangaDetail(
      id: json['id'] ?? '0',
      title: json['title'] ?? 'No Title',
      type: json['type'] ?? 'N/A',
      imageUrl: json['comic_image'] ?? '',
      rating: json['rating'] ?? 'N/A',
      chapters: chapters,
      author: json['author'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
      released: json['released'] ?? 'N/A',
      genres: genres,
    );
  }
  final String id;
  final String title;
  final String type;
  final String imageUrl;
  final String rating;
  final List<ChapterSummary> chapters;
  final String author;
  final String status;
  final String released;
  final List<String> genres;
}

class MangaSummary {

  MangaSummary({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.type = 'Manga',
    this.status = 'Ongoing',
    this.rating = 'N/A',
    this.genres = const [],
  });

  factory MangaSummary.fromJson(Map<String, dynamic> json) {
    final genresList = json['genres'] as List? ?? [];
    return MangaSummary(
      id: json['id']?.toString() ?? '0',
      title: json['title'] ?? 'No Title',
      imageUrl: json['comic_image'] ?? '',
      type: json['type'] ?? 'Manga',
      status: json['status'] ?? 'Ongoing',
      rating: json['rating'] ?? 'N/A',
      genres: genresList.cast<String>(),
    );
  }
  final String id;
  final String title;
  final String imageUrl;
  final String type;
  final String status;
  final String rating;
  final List<String> genres;
}

class ChapterSummary {

  ChapterSummary({required this.title, required this.pages});

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    final pagesList = json['images'] as List? ?? [];
    return ChapterSummary(
      title: json['chapter_title'] ?? 'No Title',
      pages: pagesList.cast<String>(),
    );
  }
  final String title;
  final List<String> pages;
}