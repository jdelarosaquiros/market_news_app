import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/favorites_cubit.dart';

import '../widgets/article_thumbnail.dart';
import 'article_preview.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

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
                        child: Text("No articles found."),
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
                        onTap: () {
                          //Todo: Move delete favorite to icon button
                          context
                              .read<FavoritesCubit>()
                              .deleteArticle(currState.news[index]);

                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return const ArticlePreview();
                            }),
                          );
                        },
                        child: ArticleThumbnail(article: currState.news[index]),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0x00000000),
                    ),
                  ),
          );
        }
        if (currState is FavoritesError) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: SizedBox(
              child: const Center(child: Icon(Icons.error_outline_rounded)),
              height: MediaQuery.of(context).size.height / 2,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
