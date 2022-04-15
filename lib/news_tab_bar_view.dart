import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/screens/article_preview.dart';
import 'package:market_news_app/services/time_helper.dart';
import 'package:market_news_app/widgets/article_thumbnail.dart';
import 'package:market_news_app/widgets/bottom_loader_indicator.dart';

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
    const double scrollThreshold = 50;
    const double offset = 1000;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if ((maxScroll - currentScroll - offset).abs() <= scrollThreshold &&
        context.read<NewsCubit>().state.status != NewsStatus.loading &&
        !_scrollController.position.outOfRange &&
        !context.read<NewsCubit>().state.hasReachedMax &&
        !isLoading) {
      isLoading = true;
      print("Here -------");
      context.read<NewsCubit>().loadNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
        appBar: AppBar(
          //toolbarHeight: 30,
          title: const Text("News"), //TODO: Replace with app icon and name
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 30),
              onPressed: () {
                // TODO: Search Function
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<NewsCubit, NewsState>(
              listener: (context, currState) {
            //_currState = currState;
            //_currContext = context;
            //if (currState.status != NewsStatus.loading) {
            //  isLoading = false;
            //}
          }, buildWhen: (prevState, currState) {
            print("List Length: ${currState.news.length}");
            print(
                "Max: Previous: ${currState.hasReachedMax}, Current: ${currState.hasReachedMax}");
            print(
                "Status: Previous: ${currState.status}, Current: ${currState.status}");

            if (prevState.status == NewsStatus.loadingMore &&
                currState.status == NewsStatus.loaded) {
              isLoading = false;
            }

            return (prevState.status != currState.status ||
                prevState.hasReachedMax != currState.hasReachedMax);
          }, builder: (context, newsState) {
            if (newsState.status == NewsStatus.loaded ||
                newsState.status == NewsStatus.loadingMore) {
              return IndexedStack(
                index: _selectedIndex,
                children: [
                  //Todo: Create widget - simplify code
                  RefreshIndicator(
                    onRefresh: () {
                      return context.read<NewsCubit>().fetchNews();
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: (newsState.hasReachedMax)
                          ? newsState.news.length
                          : newsState.news.length + 1,
                      itemBuilder: (context, index) {
                        return (index >= newsState.news.length)
                            // Todo: Replace hard coded size
                            ? const BottomLoaderIndicator()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return const ArticlePreview();
                                    }),
                                  );
                                },
                                child: ArticleThumbnail(
                                    article: newsState.news[index]),
                              );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0x00000000),
                      ),
                    ),
                  ),
                  Center(child: Text("${newsState.news.length}")),
                  Center(child: Text("${newsState.news.length}")),
                ],
              );
            }
            if (newsState.status == NewsStatus.error) {
              return const Center(child: Icon(Icons.error));
            }
            return const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }
}
