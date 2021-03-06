import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/favorites_cubit.dart';
import 'package:market_news_app/bloc/history_cubit.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:market_news_app/news_tab_bar_view.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bloc/search_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// This widget is the root of the app, and it loads initial data and sets
// default theming.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NewsCubit>(create: (context) => NewsCubit()..fetchNews()),
        BlocProvider<SearchCubit>(create: (context) => SearchCubit()),
        BlocProvider<FavoritesCubit>(
          create: (context) => FavoritesCubit()..getArticles(),
        ),
        BlocProvider<HistoryCubit>(
            create: (context) => HistoryCubit()..getArticles()),
      ],
      child: MaterialApp(
        title: 'Market News',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue[300],
          indicatorColor: Colors.lightBlue[300],
          scaffoldBackgroundColor: const Color(0x52525252),
          colorScheme: ThemeData().colorScheme.copyWith(
                primary: const Color(0x52525252),
                onPrimary: Colors.white,
                secondary: Colors.blue[300],
                onSecondary: Colors.black,
              ),
        ),
        home: const NewsTabBarView(),
      ),
    );
  }
}
