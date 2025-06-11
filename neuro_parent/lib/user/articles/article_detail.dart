import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_article_bloc.dart';
import 'package:collection/collection.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';


class ArticleDetailScreen extends ConsumerWidget {
  final int articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleState = ref.watch(userArticleProvider);
    final article = articleState.articles.firstWhereOrNull(
      (a) => a.articleId == articleId,
    );
    final isLoading = articleState.isLoading;
    final error = articleState.error;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/articles'),
        ),
        title: Text(article?.articleTitle ?? 'Article'),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : article == null
              ? const Center(child: Text('Article not found.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.articleImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          article.articleImage,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      article.articleTitle,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      article.articleContent,
                      style: const TextStyle(fontSize: 16.0, height: 1.6),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context) - 1,
      ),
    );
  }
}

int _getCurrentIndex(BuildContext context) {
  return 3;
}
