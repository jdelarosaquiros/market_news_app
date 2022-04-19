part of 'search_cubit.dart';

abstract class SearchState extends Equatable{

  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState{
  const SearchInitial();
}

class SearchLoading extends SearchState{
  const SearchLoading();
}

class SearchLoaded extends SearchState{
  final List<Article> news;

  const SearchLoaded({required this.news});

  @override
  List<Object> get props => [news];
}

class SearchError extends SearchState{
  const SearchError();
}