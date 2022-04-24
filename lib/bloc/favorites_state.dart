part of 'favorites_cubit.dart';

abstract class FavoritesState extends Equatable {
  final List<Article> news;

  const FavoritesState({required this.news});

  @override
  List<Object> get props => [news];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial({required List<Article> news}) : super(news: news);
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading({required List<Article> news}) : super(news: news);
}

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

class FavoritesError extends FavoritesState {
  const FavoritesError({required List<Article> news}) : super(news: news);
}
