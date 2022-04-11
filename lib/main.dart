import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:market_news_app/news_tab_bar_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsCubit()..fetchNews(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue[400],
          indicatorColor: Colors.lightBlue[400],
          colorScheme: ThemeData().colorScheme.copyWith(primary: Colors.grey[800],secondary: Colors.blue[600]),
        ),
        home: const NewsTabBarView(),
      ),
    );
  }
}
