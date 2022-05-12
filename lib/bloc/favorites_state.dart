part of 'favorites_cubit.dart';

/*
 * This class represents the state of favorite news list. It contains
 * the news list, and the classes representing a state extend this class.
 */

abstract class FavoritesState extends Equatable {
  final List<Article> news;

  const FavoritesState({required this.news});

  @override
  List<Object> get props => [news];
}

// Represents the initial state of the news
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial({required List<Article> news}) : super(news: news);
}

// Represents the state when the news are being loaded
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading({required List<Article> news}) : super(news: news);
}

// Represents the state when the news are loaded
class FavoritesLoaded extends FavoritesState {
  late final Map<int, Article> articleMap;

  FavoritesLoaded({required List<Article> news}) : super(news: news){
      articleMap = _convertListToMap(news);
  }

  Map<int, Article> _convertListToMap(List<Article> news) {
    Map<int, Article> articleMap = {};

    for (Article article in news) {
      articleMap[article.id] = article;
    }
    return articleMap;
  }
}

// Represents the state when there is an error
class FavoritesError extends FavoritesState {
  const FavoritesError({required List<Article> news}) : super(news: news);
}
