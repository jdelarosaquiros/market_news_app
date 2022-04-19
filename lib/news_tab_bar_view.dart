import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_news_app/screens/article_preview.dart';
import 'package:market_news_app/screens/favorites_screen.dart';
import 'package:market_news_app/screens/search_screen.dart';
import 'package:market_news_app/widgets/article_thumbnail.dart';
import 'package:market_news_app/widgets/bottom_loader_indicator.dart';

import 'bloc/favorites_cubit.dart';

class NewsTabBarView extends StatefulWidget {
  const NewsTabBarView({Key? key}) : super(key: key);

  @override
  State<NewsTabBarView> createState() => _NewsTabBarViewState();
}

class _NewsTabBarViewState extends State<NewsTabBarView> {
  int _selectedIndex = 0;
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          //toolbarHeight: 30,
          title: const Text("News"), //TODO: Replace with app icon and name
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SearchScreen();
                  }),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          currentIndex: _selectedIndex,
          selectedFontSize: 11,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          iconSize: 26,
          unselectedFontSize: 11,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
              icon: Icon(
                Icons.home_outlined,
                size: 30,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              activeIcon: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: FaIcon(
                    FontAwesomeIcons.solidClock,
                    color: Colors.white,
                    size: 25,
                  )),
              icon: Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: FaIcon(
                  FontAwesomeIcons.clock,
                  size: 25,
                ),
              ),
              label: "History",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 30,
              ),
              icon: Icon(Icons.star_outline_rounded, size: 30),
              label: "Favorites",
            ),
          ],
        ),

        body: SafeArea(
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
                  return IndexedStack(
                    index: _selectedIndex,
                    children: [
                      //Todo: Create screen with this widget tree
                      RefreshIndicator(
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
                                    onTap: () {
                                      //Todo: Move add to favorites to icon button
                                      context
                                          .read<FavoritesCubit>()
                                          .insertArticle(currState.news[index]);

                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return const ArticlePreview();
                                        }),
                                      );
                                    },
                                    child: ArticleThumbnail(
                                        article: currState.news[index]),
                                  );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: Color(0x00000000),
                          ),
                        ),
                      ),
                      Center(child: Text("${currState.news.length}")),
                      FavoritesScreen(),
                    ],
                  );
                }
                if (currState.status == NewsStatus.error) {
                  return const Center(child: Icon(Icons.error));
                }
                return const Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }
}
