import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/history_cubit.dart';
import '../bloc/news_cubit.dart';
import '../services/time_helper.dart';
import '../widgets/article_thumbnail.dart';
import '../widgets/bottom_loader_indicator.dart';
import 'article_preview.dart';

/*
 * This widget is the main/home page of the app, and it displays the latest
 * news and loads older ones when the user reaches the bottom of the list.
 * It can also be refreshed get the latest news and reset the list of news.
 */

class HomeScreen extends StatefulWidget {
  final void Function(int index) setSelectedIndex;
  final int currentIndex;

  const HomeScreen({
    Key? key,
    required this.setSelectedIndex,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TimeHelper _timeHelper = TimeHelper();
  late ScrollController _scrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // This listener loads more articles when the user reaches the bottom of
  // the list.
  void _scrollListener() {
    const double scrollThreshold = 700;
    const double offset = 0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if ((maxScroll - currentScroll - offset).abs() <= scrollThreshold &&
        context.read<NewsCubit>().state.status != NewsStatus.loading &&
        !_scrollController.position.outOfRange &&
        !context.read<NewsCubit>().state.hasReachedMax &&
        !isLoading) {
      isLoading = true;
      context.read<NewsCubit>().loadNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<NewsCubit, NewsState>(
          listener: (context, currState) {},
          buildWhen: (prevState, currState) {
            if (prevState.status == NewsStatus.loadingMore &&
                currState.status == NewsStatus.loaded) {
              isLoading = false;
            }

            return (prevState.status != currState.status ||
                prevState.hasReachedMax != currState.hasReachedMax);
          },
          builder: (context, currState) {
            if (currState.status == NewsStatus.loaded ||
                currState.status == NewsStatus.loadingMore) {
              return RefreshIndicator(
                onRefresh: () {
                  return context.read<NewsCubit>().fetchNews();
                },
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: (currState.hasReachedMax)
                      ? currState.news.length
                      : currState.news.length + 1,
                  itemBuilder: (context, index) {
                    return (index >= currState.news.length)
                        ? const BottomLoaderIndicator()
                        : GestureDetector(
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
                            child: ArticleThumbnail(
                              article: currState.news[index],
                              timeAgo: _timeHelper
                                  .relativeTime(currState.news[index].dateUnix),
                            ),
                          );
                  },
                  separatorBuilder: (context, index) => Container(
                    color: const Color(0x52525252),
                    height: 8,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              );
            }
            if (currState.status == NewsStatus.error) {
              return RefreshIndicator(
                onRefresh: () {
                  return context.read<NewsCubit>().fetchNews();
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
                          "Could not connect to the server.",
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
