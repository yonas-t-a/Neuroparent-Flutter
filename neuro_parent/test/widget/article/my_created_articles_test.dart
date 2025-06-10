import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/admin/articles/my_created_articles.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/admin/bloc/article_bloc.dart'; // Import the provider

void main() {
  group('MyCreatedArticlesPage Widget Tests', () {
    testWidgets('renders article details correctly', (
      WidgetTester tester,
    ) async {
      const jwtToken = 'test_token';
      const articleId = 1;

      final mockArticle = Article(
        articleId: articleId,
        articleTitle: 'Test Article',
        articleContent: 'This is a test article.',
        articleCategory: 'ASD',
        articleImage: '',
      );

      final mockRouter = GoRouter(
        initialLocation: '/articles',
        routes: [
          GoRoute(
            path: '/articles',
            builder:
                (context, state) => MyCreatedArticlesPage(
                  jwtToken: jwtToken,
                  articleId: articleId,
                ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            articlesFutureProvider(jwtToken).overrideWith(
              (ref) async => [mockArticle], // Mock the provider with test data
            ),
          ],
          child: MaterialApp.router(routerConfig: mockRouter),
        ),
      );

      await tester.pumpAndSettle();

      // Verify basic widgets are displayed
      expect(find.text('Edit Article'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });
}
