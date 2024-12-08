import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';

class NewsDetailsPage extends StatelessWidget {
  final Article article;

  const NewsDetailsPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          AspectRatio(
              aspectRatio: 3 / 2,
              child: Image.network(article.urlToImage ?? '')),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Text(
              article.title ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(article.description ?? ''),
          SizedBox(height: 32),
          Row(
            children: [
              Text('Auther: ${article.author}'),
              Spacer(),
              Text('Date: ${article.publishedAt}'),
            ],
          )
        ],
      ),
    );
  }
}
