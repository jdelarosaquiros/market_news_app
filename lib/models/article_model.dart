class Article {
  String category, date, title, image, source, summary, url;
  String? id;

  Article({
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
