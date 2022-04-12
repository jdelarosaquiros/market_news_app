import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article_model.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsState(news: [], status: NewsStatus.initial));

  Future<void> fetchNews() async {
    List<Article> news = [
      Article(
          id: "1234",
          category: "Category",
          date: "Date",
          title: "Title",
          image: "Image",
          source: "source",
          summary: "summary",
          url: "url"),
    ];

    emit(state.copyWith(news: news, status: NewsStatus.loading));

    try {
      saveArticlesInDatabase(news: news);
      emit(state.copyWith(news: news, status: NewsStatus.loaded));
    } catch (error) {
      emit(state.copyWith(status: NewsStatus.error));
    }
  }

  void saveArticlesInDatabase({required List<Article> news}) {
    CollectionReference articleCollection =
        FirebaseFirestore.instance.collection('articles');

    for (Article article in news) {
      articleCollection
          .doc(article.id!)
          .set({
            "category": article.category,
            "date": article.date,
            "title": article.title,
            "image": article.image,
            "source": article.source,
            "summary": article.summary,
            "url": article.url,
          })
          .then((value) =>
              print("'full_name' & 'age' merged with existing data!"))
          .catchError((error) => print("Failed to create data: $error"));
    }
  }
}
