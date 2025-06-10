import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'package:neuro_parent/user/articles/tip_list.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/user/bloc/user_article_bloc.dart';

void main() {
  group('TipsScreen Widget Tests', () {
    testWidgets('renders tips screen correctly', (WidgetTester tester) async {
      // Mock articles
      final mockArticles = [
        Article(
          articleId: 1,
          articleTitle: 'Test Tip 1',
          articleContent: 'This is a test tip content.',
          articleCategory: 'Category 1',
          articleImage: '',
        ),
        Article(
          articleId: 2,
          articleTitle: 'Test Tip 2',
          articleContent: 'Another test tip content.',
          articleCategory: 'Category 2',
          articleImage: '',
        ),
      ];

      // Mock provider
      final mockArticleState = ArticleState(articles: mockArticles);

      final mockRouter = GoRouter(
        initialLocation: '/articles',
        routes: [
          GoRoute(
            path: '/articles',
            builder: (context, state) => const TipsScreen(),
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
      expect(find.text('Tips & Tricks'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);

      // Verify articles are displayed (simplified check)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays no articles message when no articles are available', (
      WidgetTester tester,
    ) async {
      // Mock provider with no articles
      final mockArticleState = ArticleState(articles: []);

      final mockRouter = GoRouter(
        initialLocation: '/articles',
        routes: [
          GoRoute(
            path: '/articles',
            builder: (context, state) => const TipsScreen(),
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

      // Verify no articles message
      expect(find.text('No articles found.'), findsOneWidget);
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
