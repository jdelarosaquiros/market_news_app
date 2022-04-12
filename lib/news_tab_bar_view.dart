import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';

class NewsTabBarView extends StatefulWidget {
  const NewsTabBarView({Key? key}) : super(key: key);

  @override
  State<NewsTabBarView> createState() => _NewsTabBarViewState();
}

class _NewsTabBarViewState extends State<NewsTabBarView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          title: const Text("News"), //TODO: Replace with app icon and name
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 30),
              onPressed: () {
                // TODO: Search Function
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Icon(Icons.newspaper),
              Icon(Icons.history),
              Icon(Icons.star_outline_rounded),
            ],
          ),
        ),
        body: BlocConsumer<NewsCubit, NewsState>(
            listener: (context, currState) {},
            buildWhen: (prevState, currState) {
              return prevState.status != currState.status;
            },
            builder: (context, newsState) {
              if (newsState.status == NewsStatus.loaded) {
                return TabBarView(
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
