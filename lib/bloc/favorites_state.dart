part of 'favorites_cubit.dart';

abstract class FavoritesState extends Equatable{
  final List<Article> news;

  const FavoritesState({required this.news});

  @override
  List<Object> get props => [news];
}

class FavoritesInitial extends FavoritesState{

  const FavoritesInitial({required List<Article> news}) : super(news: news);

}

class FavoritesLoading extends FavoritesState{

  const FavoritesLoading({required List<Article> news}) : super(news: news);
}

class FavoritesLoaded extends FavoritesState{

  const FavoritesLoaded({required List<Article> news}) : super(news: news);

}

class FavoritesError extends FavoritesState{

  const FavoritesError({required List<Article> news}) : super(news: news);
}