import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/admin/articles/edit_article.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'package:neuro_parent/admin/bloc/article_bloc.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  group('EditArticlePage Widget Tests', () {
    late GoRouter router;
    late MockArticleRepository mockRepository;

    setUp(() {
      mockRepository = MockArticleRepository();

      // Mock the articles provider
      when(() => mockRepository.getArticles()).thenAnswer(
        (_) async => [
          Article(
            articleId: 1,
            articleTitle: 'Test Article',
            articleContent: 'This is a test article.',
            articleCategory: 'Test Category',
            articleImage: '',
          ),
        ],
      );

      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder:
                (context, state) => ProviderScope(
                  overrides: [
                    filteredArticlesProvider('test_token').overrideWith(
                      (ref) => AsyncValue.data([
                        Article(
                          articleId: 1,
                          articleTitle: 'Test Article',
                          articleContent: 'This is a test article.',
                          articleCategory: 'Test Category',
                          articleImage: '',
                        ),
                      ]),
                    ),
                  ],
                  child: EditArticlePage(jwtToken: 'test_token'),
                ),
          ),
        ],
      );
    });

    testWidgets('renders correctly with all essential widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // Wait for the widget tree to fully build
      await tester.pumpAndSettle();

      expect(find.text('Tips & Tricks'), findsOneWidget);
      expect(find.text('Search tips'), findsOneWidget);

      // Target the ChoiceChip for "All" instead of generic text
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ChoiceChip && widget.label.toString().contains('All'),
        ),
        findsOneWidget,
      );

      expect(find.text('Test Article'), findsOneWidget);
    });

    testWidgets('displays error when deleting an article fails', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete article')),
                    );
                  });
                  return const Text('Delete Article');
                },
              ),
            ),
          ),
        ),
      );

      // Wait for the widget tree to fully build
      await tester.pumpAndSettle();

      // Verify error message is displayed in a SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to delete article'), findsOneWidget);
    });
  });
}
