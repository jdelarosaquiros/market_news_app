import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {

  NewsCubit() : super(NewsState(news: [], status: NewsStatus.initial));

  Future<void> fetchNews() async {

    List<String> news = ["News 1", "News 2", "News 3"];

    emit(state.copyWith(news: news, status: NewsStatus.loading));
    news.add("News 4 ");

    try {

      emit(state.copyWith(news: news, status: NewsStatus.loaded));
    } catch (error) {
      print(error);
      emit(state.copyWith(status: NewsStatus.error));
    }
  }
}