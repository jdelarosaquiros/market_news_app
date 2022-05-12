import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:market_news_app/keys.dart';
import 'package:market_news_app/services/time_helper.dart';
import '../models/article_model.dart';
import '../services/network_helper.dart';

part 'news_state.dart';

/*
 * This class is the Cubit (state management) class for the news in the home
 * page. It contains the event functions that will change the state of the
 * news list. One function gets the 100 latest market news from the Finnhub API
 * and saves those news in a cloud database (Firestore). The other function
 * loads older news from the Firestore and appends them to the current list
 * of news.
 */

class NewsCubit extends Cubit<NewsState> {
  final int queryLimit = 3;

  NewsCubit()
      : super(const NewsState(
            news: [], status: NewsStatus.initial, hasReachedMax: false));

  // Gets the latest news and saves them on Firestore, and it updates the state
  // of the news list during the process.
  Future<void> fetchNews() async {
    List<Article> news = [];

    emit(state.copyWith(status: NewsStatus.loading));

    try {
      news = await getMarketNews();
      saveArticlesInDatabase(news: news);
      emit(state.copyWith(
          news: news, status: NewsStatus.loaded, hasReachedMax: false));
    } catch (error) {
      try {
        loadNews();
      } catch (error) {
        if (kDebugMode) {
          print(error.toString());
        }
        emit(state.copyWith(status: NewsStatus.error));
      }
    }
  }

  // Gets the 100 latest news from Finnhub API and returns them as a list of
  // Articles.
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

  // Saves the articles in the given list in Firestore
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

  // Loads more news from Firestore in order of published date and excludes
  // the news already loaded. It also updates the state of the news during
  // the process.
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
      if (kDebugMode) {
        print(error.toString());
      }
      emit(state.copyWith(status: NewsStatus.error));
    });
  }
}