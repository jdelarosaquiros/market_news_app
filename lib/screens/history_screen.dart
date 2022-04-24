import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/history_cubit.dart';

import '../widgets/article_thumbnail_miniature.dart';
import 'article_preview.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    context.read<HistoryCubit>().getArticles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<HistoryCubit, HistoryState>(
          buildWhen: (prevState, currState) {
        return (prevState != currState);
      }, builder: (context, currState) {
        if (currState is HistoryLoaded) {
          return RefreshIndicator(
            onRefresh: () {
              return context.read<HistoryCubit>().getArticles();
            },
            child: (currState.news.isEmpty)
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: SizedBox(
                      child: const Center(
                        child: Text("No visited article."),
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
                              .read<HistoryCubit>()
                              .deleteArticle(currState.news[index]);

                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return const ArticlePreview();
                            }),
                          );
                        },
                        child: ArticleThumbnailMiniature(
                          article: currState.news[index],
                          onRemoved: () {
                            context
                                .read<HistoryCubit>()
                                .deleteArticle(currState.news[index]);
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(),
                  ),
          );
        }
        if (currState is HistoryError) {
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
