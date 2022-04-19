import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/services/local_database_helper.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesInitial(news: []));

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> getArticles() async {
    List<Article> articles = [];

    emit(FavoritesLoading(news: articles));

    try {
      articles.addAll(
        await _dbHelper.queryAllArticles(DatabaseHelper.favoritesTableName),
      );
      print("Length After Getting: ${articles.length}");
      articles.sort((article1, article2) {
        return article2.dateUnix.compareTo(article1.dateUnix);
      });
      emit(FavoritesLoaded(news: articles));
    } catch (error) {
      //Todo: Implement error handling
      print(error.toString());
      emit(FavoritesError(news: articles));
    }
  }

  Future<void> insertArticle(Article article) async {

    List<Article> articles = state.news;

    if(articles.contains(article)) return;

    emit(FavoritesLoading(news: articles));

    print("Inserting");
    try {
      int id = await _dbHelper.insert(article, DatabaseHelper.favoritesTableName);
      articles.add(article);
      print("Id Inserted: $id");
      articles.sort((article1, article2) {
        return article2.dateUnix.compareTo(article1.dateUnix);
      });
      emit(FavoritesLoaded(news: articles));
    } catch (error) {
      //Todo: Implement error handling
      print(error.toString());
      emit(FavoritesError(news: articles));
    }
  }

  Future<void> deleteArticle(Article article) async {

    List<Article> articles = state.news;

    if(!articles.contains(article)) return;

    emit(FavoritesLoading(news: articles));

    try {

      int id = await _dbHelper.delete(article.id, DatabaseHelper.favoritesTableName);
      articles.remove(article);
      print("Id Deleted: $id");
      emit(FavoritesLoaded(news: articles));
    } catch (error) {
      //Todo: Implement error handling
      print(error.toString());
      emit(FavoritesError(news: articles));
    }
  }
}
