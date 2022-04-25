import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:market_news_app/screens/web_article_screen.dart';

import '../models/article_model.dart';

class ArticlePreview extends StatelessWidget {
  final Article article;
  final int selectedIndex;

  const ArticlePreview({
    Key? key,
    required this.article,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Image.network(
                  article.image,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Source: ${article.source}",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Published: ${article.date}",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  WebArticleScreen(articleUrl: article.url)));
                        },
                        child: const Text("Read Full Article"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.cyan[600],
                          onPrimary: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      "Summary",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.summary,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.4, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: selectedIndex,
        selectedFontSize: 11,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        iconSize: 26,
        unselectedFontSize: 11,
        backgroundColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          Navigator.pop(context, [index]);
        },
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.home,
              color: Colors.white,
              size: 30,
            ),
            icon: Icon(
              Icons.home_outlined,
              size: 30,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            activeIcon: Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: FaIcon(
                  FontAwesomeIcons.solidClock,
                  color: Colors.white,
                  size: 25,
                )),
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: FaIcon(
                FontAwesomeIcons.clock,
                size: 25,
              ),
            ),
            label: "History",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 30,
            ),
            icon: Icon(Icons.star_outline_rounded, size: 30),
            label: "Favorites",
          ),
        ],
      ),
    );
  }
}
