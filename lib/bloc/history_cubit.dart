import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:market_news_app/models/article_model.dart';
import 'package:market_news_app/services/local_database_helper.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryInitial(news: []));

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> getArticles() async {
    List<Article> articles = [];

    emit(HistoryLoading(news: articles));

    try {
      articles.addAll(
        await _dbHelper.queryAllArticles(DatabaseHelper.historyTableName),
      );
      articles.sort((article1, article2) {
        return article2.dateUnix.compareTo(article1.dateUnix);
      });
      emit(HistoryLoaded(news: articles));
    } catch (error) {
      //Todo: Implement error handling
      print(error.toString());
      emit(HistoryError(news: articles));
    }
  }

  Future<void> insertArticle(Article article) async {

    List<Article> articles = [...state.news];

    if(articles.any((element) => element.id == article.id)) return;

    emit(HistoryLoading(news: state.news));

    try {
      await _dbHelper.insert(article, DatabaseHelper.historyTableName);
      articles.add(article);
      articles.sort((article1, article2) {
        return article2.dateUnix.compareTo(article1.dateUnix);
      });
      emit(HistoryLoaded(news: articles));
    } catch (error) {
      //Todo: Implement error handling
      print(error.toString());
      emit(HistoryError(news: articles));
    }
  }

  Future<void> deleteArticle(Article article) async {

    List<Article> articles = [...state.news];

    if(!articles.any((element) => element.id == article.id)) return;

    emit(HistoryLoading(news: state.news));

    try {

      await _dbHelper.delete(article.id, DatabaseHelper.historyTableName);
      articles.remove(article);
      emit(HistoryLoaded(news: articles));
    } catch (error) {
      //Todo: Implement error handling
      print(error.toString());
      emit(HistoryError(news: articles));
    }
  }
}
