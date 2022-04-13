import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:market_news_app/keys.dart';
import '../models/article_model.dart';
import '../services/network_helper.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsState(news: [], status: NewsStatus.initial));

  Future<void> fetchNews() async {
    List<Article> news = [];

    emit(state.copyWith(news: news, status: NewsStatus.loading));

    try {
      news = await getMarketNews();
      saveArticlesInDatabase(news: news);
      emit(state.copyWith(news: news, status: NewsStatus.loaded));
    } catch (error) {
      //Todo: Get data from database
      print(error.toString());
      emit(state.copyWith(status: NewsStatus.error));
    }
  }

  Future<List<Article>> getMarketNews() async {
    List<Article> news = [];
    String url =
        "https://finnhub.io/api/v1/news?category=general&token=$finnhubKey";

    NetworkHelper networkHelper = NetworkHelper(url: url);
    List<dynamic> data = await networkHelper.getData();

    for (var entry in data) {

      DateTime format = DateTime.fromMillisecondsSinceEpoch(entry["datetime"] * 1000);
      String date = DateFormat.yMd().add_jm().format(format);

      news.add(Article(
        id: entry["id"],
        category: entry["category"],
        date: date,
        dateUnix: entry["datetime"],
        title: entry["headline"],
        image: entry["image"],
        source: entry["source"],
        summary: entry["summary"],
        url: entry["url"],
      ));
    }

    return news;
  }

  //Todo: Delete comments
  void saveArticlesInDatabase({required List<Article> news}) {
    CollectionReference articleCollection =
        FirebaseFirestore.instance.collection('articles');

    CollectionReference categoryCollection =
    FirebaseFirestore.instance.collection('categories');

    for (Article article in news) {
      // Save article
      articleCollection
          .doc(article.id.toString())
          .set({
            "category": article.category,
            "date": article.date,
            "dateUnix": article.dateUnix.toString(),
            "title": article.title,
            "image": article.image,
            "source": article.source,
            "summary": article.summary,
            "url": article.url,
          })
          .catchError((error) {});

      // Save category
      categoryCollection
          .doc(article.category)
          .set({"category": article.category,})
          .catchError((error) {});
    }
  }
}
