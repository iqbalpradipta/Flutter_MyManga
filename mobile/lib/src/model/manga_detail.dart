class MangaDetail {
  final int id;
  final String title;
  final String type;
  final String imageUrl;
  final String rating;
  final List<ChapterSummary> chapters;
  final String author;
  final String status;
  final String released;
  final List<String> genres;

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
    var chaptersList = json['chapters'] as List? ?? [];
    List<ChapterSummary> chapters = chaptersList.map((c) => ChapterSummary.fromJson(c)).toList();
    
    var genresList = json['genres'] as List? ?? [];
    List<String> genres = genresList.cast<String>();

    return MangaDetail(
      id: json['id'] ?? 0,
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
}

class ChapterSummary {
  final String title;
  final List<String> pages;

  ChapterSummary({required this.title, required this.pages});

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    var pagesList = json['images'] as List? ?? [];
    return ChapterSummary(
      title: json['chapter_title'] ?? 'No Title',
      pages: pagesList.cast<String>(),
    );
  }
}
