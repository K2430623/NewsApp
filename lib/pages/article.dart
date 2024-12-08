class Article {
  static const table = 'bookmarks';

  final int? id;
  final String title;
  final String source;
  final String? urlToImage;
  final String publishedAt;

  Article({
    this.id,
    required this.title,
    required this.source,
    this.urlToImage,
    required this.publishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      ArticleFields.title: title,
      ArticleFields.source: source,
      ArticleFields.urlToImage: urlToImage,
      ArticleFields.publishedAt: publishedAt,
    };
  }

  static Article fromMap(Map<String, dynamic> map) {
    return Article(
      id: map[ArticleFields.id],
      title: map[ArticleFields.title],
      source: map[ArticleFields.source],
      urlToImage: map[ArticleFields.urlToImage],
      publishedAt: map[ArticleFields.publishedAt],
    );
  }
}

class ArticleFields {
  static const String id = 'id';
  static const String title = 'title';
  static const String source = 'source';
  static const String urlToImage = 'urlToImage';
  static const String publishedAt = 'publishedAt';
}
