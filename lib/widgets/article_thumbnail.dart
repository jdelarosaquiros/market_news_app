import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/models/article_model.dart';

import '../bloc/favorites_cubit.dart';

/*
 * This is the thumbnail widget for an article. It is shown in the
 * home and search pages. It contains an image, the title,
 * the source, and the time elapsed since its publish date. It has a
 * favorite button, and users can tap it to add the article to the favorite
 * list.The constructor takes the article and the time elapsed since
 * its publish date.
 */

class ArticleThumbnail extends StatefulWidget {
  final Article article;
  final String timeAgo;

  const ArticleThumbnail({
    Key? key,
    required this.article,
    required this.timeAgo,
  }) : super(key: key);

  @override
  State<ArticleThumbnail> createState() => _ArticleThumbnailState();
}

class _ArticleThumbnailState extends State<ArticleThumbnail> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          widget.article.image,
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.width * 0.4,
          width: MediaQuery.of(context).size.width,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 5, 0),
          child: Text(
            widget.article.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.article.source}  ·  ${widget.timeAgo}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, currState) {
                  if (currState is FavoritesLoaded) {
                    bool isFavorite =
                        currState.articleMap.containsKey(widget.article.id);
                    return IconButton(
                        onPressed: () {
                          if (!isFavorite) {
                            context
                                .read<FavoritesCubit>()
                                .insertArticle(widget.article);
                          } else {
                            context
                                .read<FavoritesCubit>()
                                .deleteArticle(widget.article);
                          }
                        },
                        icon: (isFavorite)
                            ? const Icon(Icons.favorite)
                            : const Icon(Icons.favorite_border));
                  }
                  return IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                  );
                },
                buildWhen: (prevState, currState) {
                  return (prevState != currState);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
