part of 'news_cubit.dart';

enum NewsStatus { initial, loading, loadingMore, loaded, saving, saved, error }

class NewsState extends Equatable {
  List<Article> news;
  NewsStatus status;
  bool hasReachedMax;

  NewsState({
    required this.news,
    required this.status,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [news, status, hasReachedMax];

  NewsState copyWith(
      {List<Article>? news, NewsStatus? status, bool? hasReachedMax}) {
    return NewsState(
        news: news ?? this.news,
        status: status ?? this.status,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
