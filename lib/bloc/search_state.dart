part of 'search_cubit.dart';

/*
 * This class represents the state of the search list. It only stores/contains
 * the news list when they are loaded, so all other states don't have news list.
 */

abstract class SearchState extends Equatable{

  const SearchState();

  @override
  List<Object> get props => [];
}

// Represents the initial state of the news
class SearchInitial extends SearchState{
  const SearchInitial();
}

// Represents the state when the news are being loaded
class SearchLoading extends SearchState{
  const SearchLoading();
}

// Represents the state when the news are loaded and contains the list loaded
class SearchLoaded extends SearchState{
  final List<Article> news;

  const SearchLoaded({required this.news});

  @override
  List<Object> get props => [news];
}

// Represents the state when there is an error
class SearchError extends SearchState{
  const SearchError();
}