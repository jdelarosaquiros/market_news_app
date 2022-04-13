import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_news_app/bloc/news_cubit.dart';
import 'package:market_news_app/news_tab_bar_view.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewsCubit>(
      create: (context) => NewsCubit()..fetchNews(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue[300],
          indicatorColor: Colors.lightBlue[300],
          scaffoldBackgroundColor: const Color(0x12121212),
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
