import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'package:neuro_parent/user/articles/article_detail.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/user/bloc/user_article_bloc.dart';

void main() {
  group('ArticleDetailScreen Widget Tests', () {
    testWidgets('renders article detail screen correctly', (
      WidgetTester tester,
    ) async {
      // Mock article
      const articleId = 1;
      final mockArticle = Article(
        articleId: articleId,
        articleTitle: 'Test Article',
        articleContent: 'This is a test article content.',
        articleCategory: 'Category 1',
        articleImage: '',
      );

      // Mock provider
      final mockArticleState = ArticleState(articles: [mockArticle]);

      final mockRouter = GoRouter(
        initialLocation: '/articles/$articleId',
        routes: [
          GoRoute(
            path: '/articles/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return ArticleDetailScreen(articleId: id ?? 0);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userArticleProvider.overrideWith(
              (ref) =>
                  ArticleNotifier(FakeArticleRepository())
                    ..state = mockArticleState,
            ),
          ],
          child: MaterialApp.router(routerConfig: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Verify basic UI elements
      expect(
        find.text('Test Article'),
        findsWidgets,
      ); // Updated to allow multiple matches
      expect(find.text('This is a test article content.'), findsOneWidget);
    });

    testWidgets('displays article not found message when article is missing', (
      WidgetTester tester,
    ) async {
      // Mock provider with no articles
      final mockArticleState = ArticleState(articles: []);

      final mockRouter = GoRouter(
        initialLocation: '/articles/1',
        routes: [
          GoRoute(
            path: '/articles/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return ArticleDetailScreen(articleId: id ?? 0);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userArticleProvider.overrideWith(
              (ref) =>
                  ArticleNotifier(FakeArticleRepository())
                    ..state = mockArticleState,
            ),
          ],
          child: MaterialApp.router(routerConfig: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Verify article not found message
      expect(find.text('Article not found.'), findsOneWidget);
    });
  });
}

// FakeArticleRepository for testing
class FakeArticleRepository implements ArticleRepository {
  @override
  get articleService => throw UnimplementedError();

  @override
  Future<List<Article>> getArticlesByCategory(String category) async {
    return [];
  }

  @override
  Future<List<Article>> fetchArticles() async {
    return [];
  }

  @override
  Future<Article> getArticleById(int id) async {
    return Article(
      articleId: id,
      articleTitle: 'Mock Article',
      articleContent: 'Mock content',
      articleCategory: 'Mock Category',
      articleImage: '',
    );
  }

  @override
  Future<List<Article>> getArticles() async {
    return [];
  }

  @override
  Future<Article> createArticle({
    required String category,
    required String content,
    required String contentType,
    required String filename,
    required Uint8List imageBytes,
    required String title,
  }) async {
    return Article(
      articleId: 999,
      articleTitle: title,
      articleContent: content,
      articleCategory: category,
      articleImage: filename,
    );
  }

  @override
  Future<void> deleteArticle(int id) async {
    return;
  }

  @override
  Future<Article> updateArticle({
    String? category,
    String? content,
    String? contentType,
    String? filename,
    required int id,
    Uint8List? imageBytes,
    String? title,
  }) async {
    return Article(
      articleId: id,
      articleTitle: title ?? 'Updated Title',
      articleContent: content ?? 'Updated Content',
      articleCategory: category ?? 'Updated Category',
      articleImage: filename ?? '',
    );
  }
}
