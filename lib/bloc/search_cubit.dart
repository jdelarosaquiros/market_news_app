import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:market_news_app/models/article_model.dart';

part 'search_state.dart';

/*
 * This class is the Cubit (state management) class for the news in the search
 * page. It contains the event functions that will change the state of the
 * news list. It has a function to load all news containing a given text in
 *  their title. There is also another function that resets the news list.
 */

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial());

  // Resets news list to initial state
  void resetState() {
    emit(const SearchInitial());
  }

  // Searches all news containing the passed text in their title and loads them
  // on the state
  Future<void> searchArticle(String text) async {
    List<Article> articles = [];
    String title = "";

    emit(const SearchLoading());

    text = text.toLowerCase();

    FirebaseFirestore.instance
        .collection('articles')
        .orderBy('dateUnix', descending: true)
        .get()
        .then((snapShot) {
      for (QueryDocumentSnapshot doc in snapShot.docs) {
        title = (doc["title"] as String).toLowerCase();
        if (title.contains(text)) {
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
      }
      emit(SearchLoaded(news: articles));
    }).catchError((error, stackTrace) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(const SearchError());
    });
  }
}
