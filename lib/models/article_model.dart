/*
 * This class is the model for an article. It contains the following fields:
 * id, dateUnix, date, category, title, image, source, summary, url, isFavorite,
 * and dateVisited.
 */


class Article {
  String category, date, title, image, source, summary, url;
  int id, dateUnix;
  bool isFavorite;
  int? dateVisited;

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
    this.isFavorite = false,
    this.dateVisited,
  });
}
