import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/services/local_database_helper.dart';

part 'history_state.dart';

/*
 * This class is the Cubit (state management) class for the history list of
 * news. It contains the event functions that will change the state of the
 * history list. One function loads the articles from the local database, and
 * other two functions insert and delete news from the database.
 */

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryInitial(news: []));

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Loads the history list from the local database and updates
  // the state of the list during the process.
  Future<void> getArticles() async {
    List<Article> articles = [];

    emit(HistoryLoading(news: articles));

    try {
      articles.addAll(
        await _dbHelper.queryAllArticles(DatabaseHelper.historyTableName),
      );
      articles.sort((article1, article2) {
        return article2.dateVisited!.compareTo(article1.dateVisited as int);
      });
      emit(HistoryLoaded(news: articles));
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(HistoryError(news: articles));
    }
  }

  // Inserts an article to the history list, saves it on the database,
  // and updates the state of the list during the process.
  Future<void> insertArticle(Article article) async {
    List<Article> articles = [...state.news];

    if (articles.any((element) => element.id == article.id)) return;

    emit(HistoryLoading(news: state.news));

    article.dateVisited = DateTime.now().millisecondsSinceEpoch;

    try {
      await _dbHelper.insert(article, DatabaseHelper.historyTableName);
      articles.add(article);
      articles.sort((article1, article2) {
        return article2.dateVisited!.compareTo(article1.dateVisited as int);
      });
      emit(HistoryLoaded(news: articles));
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(HistoryError(news: articles));
    }
  }

  // Deletes an article from the history list and database
  // and updates the state of the list during the process.
  Future<void> deleteArticle(Article article) async {
    List<Article> articles = [...state.news];

    if (!articles.any((element) => element.id == article.id)) return;

    emit(HistoryLoading(news: state.news));

    try {
      await _dbHelper.delete(article.id, DatabaseHelper.historyTableName);
      articles.remove(article);
      emit(HistoryLoaded(news: articles));
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      emit(HistoryError(news: articles));
    }
  }
}
