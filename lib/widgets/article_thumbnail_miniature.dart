import 'package:flutter/material.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/services/time_helper.dart';

class ArticleThumbnailMiniature extends StatelessWidget {
  final Article article;

  final void Function() onRemoved;

  const ArticleThumbnailMiniature({
    Key? key,
    required this.article,
    required this.onRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeAgo = TimeHelper().relativeTime(article.dateUnix);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            article.image,
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height * 0.11,
            width: MediaQuery.of(context).size.width * 0.38,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                //width: MediaQuery.of(context).size.width * 0.42,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(height: 1.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "${article.source}  ·  $timeAgo",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(
              minHeight: 40,
              minWidth: 40,
            ),
            iconSize: 20,
            onPressed: onRemoved,
            icon: const Icon(Icons.close),
          )
        ],
      ),
    );
  }
}
