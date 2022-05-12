part of 'history_cubit.dart';

/*
 * This class represents the state of history news list. It contains
 * the news list, and the classes representing a state extend this class.
 */

abstract class HistoryState extends Equatable{
  final List<Article> news;

  const HistoryState({required this.news});

  @override
  List<Object> get props => [news];
}

// Represents the initial state of the news
class HistoryInitial extends HistoryState{

  const HistoryInitial({required List<Article> news}) : super(news: news);

}

// Represents the state when the news are being loaded
class HistoryLoading extends HistoryState{

  const HistoryLoading({required List<Article> news}) : super(news: news);
}

// Represents the state when the news are loaded
class HistoryLoaded extends HistoryState{

  const HistoryLoaded({required List<Article> news}) : super(news: news);

}

// Represents the state when there is an error
class HistoryError extends HistoryState{

  const HistoryError({required List<Article> news}) : super(news: news);
}