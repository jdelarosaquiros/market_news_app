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
            news: [], status: NewsStatus.initial, hasReachedMax: false));

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
      //Todo: Get data from database and throw error from network helper
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

  Future<void> loadNews() async {
    List<Article> articles = [];

    emit(state.copyWith(status: NewsStatus.loadingMore));

    String lastArticleId = state.news[state.news.length - 1].id.toString();
    Query articleQuery = FirebaseFirestore.instance
        .collection('articles')
        .orderBy('dateUnix').limit(queryLimit);

    if (state.news.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('articles')
          .doc(lastArticleId)
          .get()
          .then((document) {
        if (document.exists) {
          print("Exist");
          articleQuery.startAfterDocument(document);
        }
      });
    }

    articleQuery.get().then((snapShot) {
      List<Article> oldNews = state.news;
      int oldLength = oldNews.length;
      List<QueryDocumentSnapshot> docs = snapShot.docs;
      // print("Doc Length: ${docs.length}");
      // print("Current: ${oldNews[state.news.length - 1].title}");
      // print("Found: ${docs[docs.length - 1]["title"]}");
      // for (QueryDocumentSnapshot doc in docs) {
      //   print(doc["title"]);
      // }
      //Todo: Fix or delete condition - might never be true
      if (docs.length < queryLimit) {
        print("Reached End1");
        emit(state.copyWith(hasReachedMax: true));
      }
      if (docs[docs.length - 1].id == lastArticleId) {
        print("Reached End2");
        for(int i=0; i<queryLimit; i++){
          if(docs[i].id != oldNews[oldLength - queryLimit + i].id.toString()){
            articles.add(Article(
              id: int.parse(docs[i].id),
              dateUnix: int.parse(docs[i]["dateUnix"]),
              category: docs[i]["category"],
              date: docs[i]["date"],
              title: docs[i]["title"],
              image: docs[i]["image"],
              source: docs[i]["source"],
              summary: docs[i]["summary"],
              url: docs[i]["url"],
            ));
          }
        }
        emit(state.copyWith(status: NewsStatus.loaded, hasReachedMax: true));
      } else {
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
          news: [...state.news, ...articles],
          status: NewsStatus.loaded,
        ));
      }
    }).catchError((error) {
      //Todo: Fix this error
      print(error.toString());
      emit(state.copyWith(status: NewsStatus.error));
    });
  }

  //Todo: Delete comments
  void saveArticlesInDatabase({required List<Article> news}) {
    CollectionReference articleCollection =
        FirebaseFirestore.instance.collection('articles');

    CollectionReference categoryCollection =
        FirebaseFirestore.instance.collection('categories');

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
}
