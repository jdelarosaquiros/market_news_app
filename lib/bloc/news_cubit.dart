import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_news_app/keys.dart';
import 'package:market_news_app/services/time_helper.dart';
import '../models/article_model.dart';
import '../services/network_helper.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final int queryLimit = 3;

  NewsCubit()
      : super(NewsState(
            news: const [], status: NewsStatus.initial, hasReachedMax: false));

  Future<void> fetchNews() async {
    List<Article> news = [];

    emit(state.copyWith(status: NewsStatus.loading));

    try {
      //Todo: Change loading states - include saving and saved
      news = await getMarketNews();
      saveArticlesInDatabase(news: news);
      emit(state.copyWith(
          news: news, status: NewsStatus.loaded, hasReachedMax: false));
    } catch (error) {
      loadNews();
      print(error.toString());
      emit(state.copyWith(status: NewsStatus.error));
    }
  }

  Future<List<Article>> getMarketNews() async {
    List<Article> news = [];
    String title;
    String url =
        "https://finnhub.io/api/v1/news?category=general&token=$finnhubKey";

    NetworkHelper networkHelper = NetworkHelper(url: url);
    List<dynamic> data = await networkHelper.getData();
    TimeHelper timeHelper = TimeHelper();

    for (var entry in data) {
      title = entry["headline"] as String;
      news.add(Article(
        id: entry["id"],
        category: entry["category"],
        date: timeHelper.dateFromTimestamp(entry["datetime"]),
        dateUnix: entry["datetime"],
        title: (title[0] == ':') ? title.substring(2) : title,
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

    for (Article article in news) {
      // Save article
      articleCollection.doc(article.id.toString()).set({
        "category": article.category,
        "date": article.date,
        "dateUnix": article.dateUnix.toString(),
        "title": article.title,
        "image": article.image,
        "source": article.source,
        "summary": article.summary,
        "url": article.url,
      }).catchError((error) {});
    }
  }

  Future<void> loadNews() async {
    List<Article> articles = [];
    Query articleQuery;
    String lastArticleDate;

    emit(state.copyWith(status: NewsStatus.loadingMore));

    if (state.news.isNotEmpty) {
      lastArticleDate = state.news[state.news.length - 1].dateUnix.toString();
      articleQuery = FirebaseFirestore.instance
          .collection('articles')
          .orderBy('dateUnix', descending: true)
          .where('dateUnix', isLessThan: lastArticleDate);
    } else {
      articleQuery = FirebaseFirestore.instance
          .collection('articles')
          .orderBy('dateUnix', descending: true);
    }

    articleQuery.limit(queryLimit).get().then((snapShot) {
      List<QueryDocumentSnapshot> docs = snapShot.docs;

      if (docs.length < queryLimit) {
        emit(state.copyWith(status: NewsStatus.loaded, hasReachedMax: true));
      }

      for (QueryDocumentSnapshot doc in docs) {
        articles.add(Article(
          id: int.parse(doc.id),
          dateUnix: int.parse(doc["dateUnix"]),
          category: doc["category"],
          date: doc["date"],
          title: doc["title"],
          image: doc["image"],
          source: doc["source"],
          summary: doc["summary"],
          url: doc["url"],
        ));
      }
      emit(state.copyWith(
          news: [...state.news, ...articles], status: NewsStatus.loaded));
    }).catchError((error) {
      //Todo: Fix this error
      print(error.toString());
      emit(state.copyWith(status: NewsStatus.error));
    });
  }
}