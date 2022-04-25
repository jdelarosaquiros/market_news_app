import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/history_cubit.dart';
import '../bloc/news_cubit.dart';
import '../services/time_helper.dart';
import '../widgets/article_thumbnail.dart';
import '../widgets/bottom_loader_indicator.dart';
import 'article_preview.dart';

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

  void _scrollListener() {
    const double scrollThreshold = 400;
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
                        // Todo: Replace hard coded size
                        ? const BottomLoaderIndicator()
                        : GestureDetector(
                            onTap: () async {
                              //Todo: Move add to favorites to icon button
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
                              if(args == null) return;

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
              return const Center(child: Icon(Icons.error));
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
