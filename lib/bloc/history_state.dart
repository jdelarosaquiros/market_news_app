part of 'history_cubit.dart';

abstract class HistoryState extends Equatable{
  final List<Article> news;

  const HistoryState({required this.news});

  @override
  List<Object> get props => [news];
}

class HistoryInitial extends HistoryState{

  const HistoryInitial({required List<Article> news}) : super(news: news);

}

class HistoryLoading extends HistoryState{

  const HistoryLoading({required List<Article> news}) : super(news: news);
}

class HistoryLoaded extends HistoryState{

  const HistoryLoaded({required List<Article> news}) : super(news: news);

}

class HistoryError extends HistoryState{

  const HistoryError({required List<Article> news}) : super(news: news);
}