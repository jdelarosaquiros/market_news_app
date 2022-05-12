import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/history_cubit.dart';

import '../services/time_helper.dart';
import '../widgets/article_thumbnail_miniature.dart';
import 'article_preview.dart';

/*
 * This page displays the list of articles in the history list. Articles can
 * be added to this list when users visit the preview page of the article.
 * It can be removed by tapping the remove button in an article's miniature
 * thumbnail. It can also be refreshed in case something goes wrong and the
 * articles are not loaded.
 */

class HistoryScreen extends StatefulWidget {
  final void Function(int index) setSelectedIndex;
  final int currentIndex;

  const HistoryScreen({
    Key? key,
    required this.setSelectedIndex,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TimeHelper _timeHelper = TimeHelper();

  @override
  void initState() {
    context.read<HistoryCubit>().getArticles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _currTime = "";

    return SafeArea(
      child: BlocBuilder<HistoryCubit, HistoryState>(
          buildWhen: (prevState, currState) => (prevState != currState),
          builder: (context, currState) {
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
                        itemCount: currState.news.length + 1,
                        itemBuilder: (context, index) {
                          // normalize index for array
                          index--;

                          if(index == -1) {
                            String timeAgo = _timeHelper.relativeTime(
                                currState.news[index + 1].dateVisited as int);

                            if (timeAgo.contains(RegExp(r"now|minute|hour"))) {
                              timeAgo = "Today";
                            }
                            _currTime = timeAgo;

                            return Padding(
                              padding:
                              const EdgeInsets.fromLTRB(10, 20, 0, 10),
                              child: Text(
                                timeAgo,
                                style:
                                Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.start,
                              ),
                            );
                          }

                          return GestureDetector(
                                  onTap: () async {
                                    List<int>? args =
                                        await Navigator.of(context)
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
                                    onRemoved: () {
                                      context
                                          .read<HistoryCubit>()
                                          .deleteArticle(currState.news[index]);
                                    },
                                  ),
                                );
                        },
                        separatorBuilder: (context, index) {
                          bool isTimeDifferent = false;
                          String timeAgo = _timeHelper.relativeTime(
                              currState.news[index].dateVisited as int);

                          if (timeAgo.contains(RegExp(r"now|minute|hour"))) {
                            timeAgo = "Today";
                          }
                          if (timeAgo != _currTime) {
                            _currTime = timeAgo;
                            isTimeDifferent = true;
                          }

                          return (isTimeDifferent)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 20, 0, 10),
                                  child: Text(
                                    timeAgo,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
              );
            }
            if (currState is HistoryError) {
              return RefreshIndicator(
                onRefresh: () {
                  return context.read<HistoryCubit>().getArticles();
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
                          "Error occurred while loading history",
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
