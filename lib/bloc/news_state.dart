part of 'news_cubit.dart';

/*
 * This class represents the state of the news in the home page. It contains
 * the properties of the state: news list, status, and whether it has reached
 * maximum news available, and it updates them depending on the parameters
 * passed when creating a new state.
 */

enum NewsStatus { initial, loading, loadingMore, loaded, saving, saved, error }

class NewsState extends Equatable {
  final List<Article> news;
  final NewsStatus status;
  final bool hasReachedMax;

  const NewsState({
    required this.news,
    required this.status,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [news, status, hasReachedMax];

  // If a parameter of a property is not passed, it creates the new state with
  // the current value of that property.
  NewsState copyWith(
      {List<Article>? news, NewsStatus? status, bool? hasReachedMax}) {
    return NewsState(
        news: news ?? this.news,
        status: status ?? this.status,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
