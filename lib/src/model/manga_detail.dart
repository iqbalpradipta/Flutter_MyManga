class MangaDetail {
  final int id;
  final String title;
  final String japaneseTitle;
  final String score;
  final String producer;
  final String type;
  final String status;
  final String totalEpisode;
  final String duration;
  final String releaseDate;
  final String studio;
  final String genre;
  final String synopsis;
  final String imageUrl;
  final List<ChapterSummary> chapters;

  MangaDetail({
    required this.id,
    required this.title,
    this.japaneseTitle = '',
    this.score = '',
    this.producer = '',
    this.type = '',
    this.status = '',
    this.totalEpisode = '',
    this.duration = '',
    this.releaseDate = '',
    this.studio = '',
    this.genre = '',
    this.synopsis = '',
    required this.imageUrl,
    required this.chapters,
  });

  factory MangaDetail.fromJson(Map<String, dynamic> json) {
    var chaptersList = json['chapters'] as List? ?? [];
    List<ChapterSummary> chapters = chaptersList
        .map((c) => ChapterSummary.fromJson(c))
        .toList();

    return MangaDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      japaneseTitle: json['japanese_title'] ?? '',
      score: json['rating'] ?? '',
      producer: json['producer'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      totalEpisode: json['total_episode']?.toString() ?? '',
      duration: json['duration'] ?? '',
      releaseDate: json['release_date'] ?? '',
      studio: json['studio'] ?? '',
      genre: json['genre'] ?? '',
      synopsis: json['synopsis'] ?? 'Tidak ada sinopsis.',
      imageUrl: json['comic_image'] ?? '',
      chapters: chapters,
    );
  }
}

class ChapterSummary {
  final String title;
  final List<String> pages;

  ChapterSummary({required this.title, required this.pages});

  factory ChapterSummary.fromJson(Map<String, dynamic> json) {
    var pagesList = json['images'] as List? ?? [];
    List<String> pages = pagesList.cast<String>();
    return ChapterSummary(title: json['chapter_title'] ?? '', pages: pages);
  }
}
