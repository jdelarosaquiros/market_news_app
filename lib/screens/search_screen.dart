import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_cubit.dart';
import '../bloc/search_cubit.dart';
import '../services/time_helper.dart';
import '../widgets/article_thumbnail.dart';
import 'article_preview.dart';

class SearchScreen extends StatefulWidget {
  final void Function(int index) setSelectedIndex;
  final int currentIndex;

  const SearchScreen({
    Key? key,
    required this.setSelectedIndex,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TimeHelper _timeHelper = TimeHelper();
  String _text = "";

  @override
  void initState() {
    context.read<SearchCubit>().resetState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            height: kToolbarHeight * 0.6,
            //width: MediaQuery.of(context).size.width * 0.7,
            child: Row(children: [
              Expanded(
                  child: TextFormField(
                onChanged: (value) => _text = value,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) {
                  context.read<SearchCubit>().searchArticle(_text);
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 10,
                  ),
                ),
              ))
            ]),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.all(Radius.circular(7))),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<SearchCubit, SearchState>(
              buildWhen: (prevState, currState) {
            return (prevState != currState);
          }, builder: (context, currState) {
            if (currState is SearchLoaded) {
              return (currState.news.isEmpty)
                  ? const Center(child: Text("No articles found."))
                  : RefreshIndicator(
                      onRefresh: () {
                        return context.read<SearchCubit>().searchArticle(_text);
                      },
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: currState.news.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<HistoryCubit>()
                                  .insertArticle(currState.news[index]);

                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return ArticlePreview(
                                    article: currState.news[index],
                                    selectedIndex: 0,
                                  );
                                }),
                              );
                            },
                            child: ArticleThumbnail(
                              article: currState.news[index],
                              timeAgo: _timeHelper
                                  .relativeTime(currState.news[index].dateUnix),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => Container(
                          color: const Color(0x52525252),
                          height: 8,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    );
            }
            if (currState is SearchError) {
              return const Center(child: Icon(Icons.error));
            }
            if (currState is SearchInitial) {
              return Container();
            }
            return const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }
}
