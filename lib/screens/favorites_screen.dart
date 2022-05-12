import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/favorites_cubit.dart';
import '../bloc/history_cubit.dart';
import '../widgets/article_thumbnail_miniature.dart';
import 'article_preview.dart';

/*
 * This page displays the list of articles in the favorite list. Articles can
 * be added and removed to this list by tapping the hearts symbol in an
 * article's thumbnail. It can also be removed by tapping the remove button in
 * an article's miniature thumbnail. It can also be refreshed in case something
 * goes wrong and the articles are not loaded.
 */

class FavoritesScreen extends StatefulWidget {
  final void Function(int index) setSelectedIndex;
  final int currentIndex;

  const FavoritesScreen({
    Key? key,
    required this.setSelectedIndex,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    context.read<FavoritesCubit>().getArticles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<FavoritesCubit, FavoritesState>(
          buildWhen: (prevState, currState) {
        return (prevState != currState);
      }, builder: (context, currState) {
        if (currState is FavoritesLoaded) {
          return RefreshIndicator(
            onRefresh: () {
              return context.read<FavoritesCubit>().getArticles();
            },
            child: (currState.news.isEmpty)
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: SizedBox(
                      child: const Center(
                        child: Text("No added article."),
                      ),
                      height: MediaQuery.of(context).size.height / 2,
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: currState.news.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          context
                              .read<HistoryCubit>()
                              .insertArticle(currState.news[index]);

                          List<int>? args = await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) => ArticlePreview(
                              article: currState.news[index],
                              selectedIndex: widget.currentIndex,
                            ),
                          ));
                          if (args == null) return;

                          widget.setSelectedIndex(args[0]);
                        },
                        child: ArticleThumbnailMiniature(
                          article: currState.news[index],
                          onRemoved: () => context
                              .read<FavoritesCubit>()
                              .deleteArticle(currState.news[index]),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(),
                  ),
          );
        }
        if (currState is FavoritesError) {
          return RefreshIndicator(
            onRefresh: () {
              return context.read<FavoritesCubit>().getArticles();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: SizedBox(
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 34,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Error occurred while loading favorites.",
                          style: Theme.of(context).textTheme.labelLarge,
                        )
                      ],
                    )),
                height: MediaQuery.of(context).size.height / 2,
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
