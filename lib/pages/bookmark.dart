import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:thenewsapppartb/pages/news_details_page.dart';

class BookmarkPage extends StatefulWidget {
  final List<Article> bookmarkedArticles;
  final Function(Article) onRemoveBookmark; // Callback to update parent state

  const BookmarkPage({
    super.key,
    required this.bookmarkedArticles,
    required this.onRemoveBookmark,
  });

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late List<Article> bookmarks;

  @override
  void initState() {
    super.initState();
    bookmarks = List.from(widget.bookmarkedArticles); // Clone the original list
  }

  void _removeBookmark(Article article) {
    setState(() {
      bookmarks.remove(article);
      widget.onRemoveBookmark(article); // Notify the parent about the removal
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarked Articles"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SafeArea(
        child: bookmarks.isNotEmpty
            ? ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            final article = bookmarks[index];
            return _buildBookmarkedItem(context, article);
          },
        )
            : const Center(
          child: Text(
            "No articles bookmarked yet.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkedItem(BuildContext context, Article article) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? "No title available",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.source?.name ?? "Unknown source",
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeBookmark(article),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              tooltip: "Remove Bookmark",
            ),
          ],
        ),
      ),
    );
  }
}
