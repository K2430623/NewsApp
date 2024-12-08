import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:thenewsapppartb/pages/bookmark.dart';
import 'package:thenewsapppartb/pages/category_news_page.dart';
import 'package:thenewsapppartb/pages/news_details_page.dart';
import 'package:thenewsapppartb/pages/search_page.dart';

class NewsPage extends StatefulWidget {
  final String country;

  NewsPage({super.key, required this.country});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  TextEditingController searchController = TextEditingController();

  late Future<List<Article>> future;
  List<String> categoryItems = [
    "GENERAL",
    "ENTERTAINMENT",
    "BUSINESS",
    "HEALTH",
    "SPORTS",
    "SCIENCE",
  ];

  late String selectedCategory;
  late String selectedCountry;

  List<Article> bookmarkedArticles = [];
  List<Article> currentArticles = [];

  @override
  void initState() {
    selectedCategory = categoryItems[0];
    selectedCountry = widget.country;
    future = getNewsData();
    super.initState();
  }

  Future<List<Article>> getNewsData() async {
    NewsAPI newsAPI = NewsAPI(apiKey: '0994a16cd86b48b2b7cbb1f0ff675f70');
    return await newsAPI.getTopHeadlines(
      country: selectedCountry,
      category: selectedCategory,
      pageSize: 50,
    );
  }

  void sortArticlesByTitle() {
    setState(() {
      currentArticles.sort((a, b) => a.title!.compareTo(b.title!));
    });
  }

  void sortArticlesByDate() {
    setState(() {
      currentArticles.sort((a, b) => b.publishedAt!.compareTo(a.publishedAt!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Article>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading the news"),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    currentArticles = snapshot.data!;
                    return _buildNewsListView(currentArticles);
                  } else {
                    return const Center(
                      child: Text("No news available"),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    String title;
    if (widget.country == 'in') {
      title = 'India NEWS';
    } else if (widget.country == 'au') {
      title = 'Australia NEWS';
    } else {
      title = 'NEWS';
    }
    return AppBar(
      backgroundColor: Colors.orangeAccent,
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(country: widget.country),
              ),
            );
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookmarkPage(
                  bookmarkedArticles: bookmarkedArticles,
                  onRemoveBookmark: (Article article) {
                    setState(() {
                      bookmarkedArticles.remove(article);
                    });
                  },
                ),
              ),
            );
            setState(() {});  // Refresh the state when returning from BookmarkPage
          },
          icon: const Icon(Icons.bookmark),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (value) {
            if (value == 'title') {
              sortArticlesByTitle();
            } else if (value == 'date') {
              sortArticlesByDate();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'title',
              child: Text('Sort by Title'),
            ),
            const PopupMenuItem(
              value: 'date',
              child: Text('Sort by Date'),
            ),
          ],
        ),
        // Add category dropdown to the AppBar
        DropdownButton<String>(
          value: selectedCategory,
          icon: const Icon(Icons.category),
          underline: Container(),
          onChanged: (String? newCategory) {
            setState(() {
              selectedCategory = newCategory!;
              future = getNewsData();
            });
          },
          items: categoryItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        Article article = articleList[index];
        return _buildNewsItem(article);
      },
      itemCount: articleList.length,
    );
  }

  Widget _buildNewsItem(Article article) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailsPage(article: article),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.network(
                  article.urlToImage ?? "",
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title!,
                      maxLines: 2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      article.source.name!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  bookmarkedArticles.contains(article)
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  color: Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    if (bookmarkedArticles.contains(article)) {
                      bookmarkedArticles.remove(article);
                    } else {
                      bookmarkedArticles.add(article);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
