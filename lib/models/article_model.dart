class Article {
  String category, date, title, image, source, summary, url;
  int id, dateUnix;

  Article({
    required this.id,
    required this.dateUnix,
    required this.category,
    required this.date,
    required this.title,
    required this.image,
    required this.source,
    required this.summary,
    required this.url,
  });
}
