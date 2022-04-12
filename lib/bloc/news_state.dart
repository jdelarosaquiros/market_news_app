part of 'news_cubit.dart';

enum NewsStatus { initial, loading, loaded, error }

class NewsState extends Equatable {
  List<Article> news;
  NewsStatus status;

  NewsState({required this.news, required this.status});

  @override
  List<Object?> get props => [news, status];

  NewsState copyWith({List<Article>? news, NewsStatus? status}) {
    return NewsState(
      news: news ?? this.news,
      status: status ?? this.status,
    );
  }
}
