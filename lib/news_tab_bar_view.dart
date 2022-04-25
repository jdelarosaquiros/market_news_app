import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_news_app/screens/article_preview.dart';
import 'package:market_news_app/screens/favorites_screen.dart';
import 'package:market_news_app/screens/history_screen.dart';
import 'package:market_news_app/screens/home_screen.dart';
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
  int selectedIndex = 0;
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

  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
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
          title: (selectedIndex == 0)
              ? const Text("News")
              : (selectedIndex == 1)
                  ? const Text("History")
                  : const Text("Favorites"),
          //TODO: Replace with app icon and name
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SearchScreen(
                      setSelectedIndex: setSelectedIndex,
                      currentIndex: selectedIndex,
                    );
                  }),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          currentIndex: selectedIndex,
          selectedFontSize: 11,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          iconSize: 26,
          unselectedFontSize: 11,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onTap: (index) {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            }
            setState(() {
              selectedIndex = index;
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
          child: IndexedStack(
            index: selectedIndex,
            children: [
              HomeScreen(
                setSelectedIndex: setSelectedIndex,
                currentIndex: selectedIndex,
              ),
              HistoryScreen(
                setSelectedIndex: setSelectedIndex,
                currentIndex: selectedIndex,
              ),
              FavoritesScreen(
                setSelectedIndex: setSelectedIndex,
                currentIndex: selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
