import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:market_news_app/models/article_model.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial());

  void resetState() {
    emit(const SearchInitial());
  }

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
      //Todo: Implement error handling
      print(error.toString());
      emit(const SearchError());
    });
  }
}
