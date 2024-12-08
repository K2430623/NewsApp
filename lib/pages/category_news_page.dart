import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:thenewsapppartb/pages/news_details_page.dart';
import 'bookmark.dart';

class CategoryNewsPage extends StatefulWidget {
  final String country;
  final String category;

  CategoryNewsPage({
    super.key,
    required this.country,
    required this.category,
  });

  @override
  State<CategoryNewsPage> createState() => _CategoryNewsPageState();
}

class _CategoryNewsPageState extends State<CategoryNewsPage> {
  TextEditingController searchController = TextEditingController();
  late Future<List<Article>> future;
  static List<Article> bookmarkedArticles = [];
  String? searchTerm;
  bool isSearching = false;
  bool isSortedByTitle = false;
  bool isSortedByDate = false;

  late String selectedCategory;
  late String selectedCountry;

  @override
  void initState() {
    selectedCountry = widget.country;
    selectedCategory = widget.category;
    future = getNewsData();
    super.initState();
  }

  Future<List<Article>> getNewsData() async {
    NewsAPI newsAPI = NewsAPI(apiKey: '0994a16cd86b48b2b7cbb1f0ff675f70');
    var articles = await newsAPI.getTopHeadlines(
      country: selectedCountry,
      query: searchTerm,
      category: selectedCategory,
      pageSize: 50,
    );

    // Sorting logic
    if (isSortedByTitle) {
      articles.sort((a, b) => (a.title ?? "").compareTo(b.title ?? ""));
    } else if (isSortedByDate) {
      articles.sort((a, b) => (b.publishedAt ?? DateTime.now())
          .compareTo(a.publishedAt ?? DateTime.now()));
    }

    return articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearching ? searchAppBar() : defaultAppBar(),
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
                  } else {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _buildNewsListView(snapshot.data!);
                    } else {
                      return const Center(
                        child: Text("No news available"),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar searchAppBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            isSearching = false;
            searchTerm = null;
            searchController.text = "";
            future = getNewsData();
          });
        },
      ),
      title: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white70),
        cursorColor: Colors.white70,
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              searchTerm = searchController.text;
              future = getNewsData();
            });
          },
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  AppBar defaultAppBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      title: Text('${widget.category} News'.toUpperCase()),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = true;
            });
          },
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookmarkPage(
                  bookmarkedArticles: bookmarkedArticles, onRemoveBookmark: (Article ) {  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.bookmark),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              if (value == 'Sort by Title') {
                isSortedByTitle = true;
                isSortedByDate = false;
              } else if (value == 'Sort by Date') {
                isSortedByDate = true;
                isSortedByTitle = false;
              }
              future = getNewsData();
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'Sort by Title',
              child: Text('Sort by Title'),
            ),
            const PopupMenuItem(
              value: 'Sort by Date',
              child: Text('Sort by Date'),
            ),
          ],
          icon: const Icon(Icons.sort),
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
    bool isBookmarked = bookmarkedArticles.contains(article);
    return Card(
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
                    article.title ?? '',
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    article.source.name ?? '',
                    style: const TextStyle(color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  if (isBookmarked) {
                    bookmarkedArticles.remove(article);
                  } else {
                    bookmarkedArticles.add(article);
                  }
                });
              },
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Object {
  compareTo(Object object) {}
}
