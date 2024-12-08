import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:thenewsapppartb/pages/category_news_page.dart';
import 'package:thenewsapppartb/pages/news_details_page.dart';

class SearchPage extends StatefulWidget {
  String country;

  SearchPage({super.key, required this.country});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  late Future<List<Article>> future;
  String? searchTerm;
  late String selectedCountry;

  @override
  void initState() {
    selectedCountry = widget.country;
    future = getNewsData();
    super.initState();
  }

  Future<List<Article>> getNewsData() async {
    NewsAPI newsAPI = NewsAPI(apiKey: '0994a16cd86b48b2b7cbb1f0ff675f70');
    return await newsAPI.getTopHeadlines(
      country: selectedCountry,
      query: searchTerm,
      pageSize: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchAppBar(),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: FutureBuilder(
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
                          return _buildNewsListView((snapshot.data as List<Article>)
                              .where((element) => element.title != '[Removed]')
                              .toList());
                        } else {
                          return const Center(
                            child: Text("No news available"),
                          );
                        }
                      }
                    },
                    future: future,
                  )),
            ],
          )),
    );
  }

  searchAppBar() {
    return AppBar(
      backgroundColor: Colors.orangeAccent,
      title: TextField(
        controller: searchController,
        style: TextStyle(color: Colors.black87),
        cursorColor: Colors.black87,
        decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.black87),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            )),
      ),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                searchTerm = searchController.text;
                future = getNewsData();
              });
            },
            icon: const Icon(Icons.search)),
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
            ));
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

}
