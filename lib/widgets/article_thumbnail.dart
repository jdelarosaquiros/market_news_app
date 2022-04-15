import 'package:flutter/material.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/services/time_helper.dart';

class ArticleThumbnail extends StatelessWidget {
  final Article article;

  const ArticleThumbnail({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeAgo = TimeHelper().relativeTime(article.dateUnix);

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            article.image,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.width * 0.4,
            width: MediaQuery.of(context).size.width,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              article.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
            child: Text(
              "${article.source}  ·  $timeAgo",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
