class ArticleModel {
  String category, date, title, image, source, summary, url;
  int? id;

  ArticleModel({
    this.id,
    required this.category,
    required this.date,
    required this.title,
    required this.image,
    required this.source,
    required this.summary,
    required this.url,
  });
}
