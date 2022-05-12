import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/services/local_database_helper.dart';

part 'favorites_state.dart';

/*
 * This class is the Cubit (state management) class for the favorite list of
 * news. It contains the event functions that will change the state of the
 * favorite list. One function loads the articles from the local database, and
 * other two functions insert and delete news from the database.
 */

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesInitial(news: []));

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Loads the favorite list of news from the local database and updates
  // the state of the list during the process.
  Future<void> getArticles() async {
    List<Article> articles = [];

    emit(FavoritesLoading(news: articles));

    try {
      articles.addAll(
        await _dbHelper.queryAllArticles(DatabaseHelper.favoritesTableName),
      );
      articles.sort((article1, article2) {
        return article2.dateUnix.compareTo(article1.dateUnix);
      });
      emit(FavoritesLoaded(news: articles));
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(FavoritesError(news: articles));
    }
  }

  // Inserts an article to the favorite news list, saves it on the database,
  // and updates the state of the list during the process.
  Future<void> insertArticle(Article article) async {

    List<Article> articles = [...state.news];

    if(articles.any((element) => element.id == article.id)) return;

    emit(FavoritesLoading(news: state.news));

    try {
      await _dbHelper.insert(article, DatabaseHelper.favoritesTableName);
      articles.add(article);
      articles.sort((article1, article2) {
        return article2.dateUnix.compareTo(article1.dateUnix);
      });
      emit(FavoritesLoaded(news: articles));
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(FavoritesError(news: articles));
    }
  }

  // Deletes an article from the favorite list and the database
  // and updates the state of the list during the process.
  Future<void> deleteArticle(Article article) async {

    List<Article> articles = [...state.news];

    if(!articles.any((element) => element.id == article.id)) return;

    emit(FavoritesLoading(news: state.news));

    try {

      await _dbHelper.delete(article.id, DatabaseHelper.favoritesTableName);
      articles.removeWhere((element) => element.id == article.id);
      emit(FavoritesLoaded(news: articles));
    } catch (error) {
      emit(FavoritesError(news: articles));
    }
  }
}
