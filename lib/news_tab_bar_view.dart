import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewsTabBarView extends StatefulWidget {
  const NewsTabBarView({Key? key}) : super(key: key);

  @override
  State<NewsTabBarView> createState() => _NewsTabBarViewState();
}

class _NewsTabBarViewState extends State<NewsTabBarView> {
  int _selectedIndex = 0;

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
          // bottom: const TabBar(
          //   tabs: [
          //     Icon(Icons.newspaper),
          //     Icon(Icons.history),
          //     Icon(Icons.star_outline_rounded),
          //   ],
          // ),
        ),
        body: BlocConsumer<NewsCubit, NewsState>(
            listener: (context, currState) {},
            buildWhen: (prevState, currState) {
              return prevState.status != currState.status;
            },
            builder: (context, newsState) {
              if (newsState.status == NewsStatus.loaded) {
                return IndexedStack(
                  index: _selectedIndex,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("${newsState.status}")),
                        Center(child: Text("${newsState.news.length}")),
                        SizedBox(height: 30),
                        FloatingActionButton(
                          onPressed: () {},
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    Center(child: Text("${newsState.news.length}")),
                    Center(child: Text("${newsState.news.length}")),
                  ],
                );
              } else {
                return Center(child: Text("${newsState.status}"));
              }
            }),
      ),
    );
  }
}
