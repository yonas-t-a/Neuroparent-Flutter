import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/admin/articles/create_article.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('CreateArticlePage Widget Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => CreateArticlePage(jwtToken: 'test_token'),
          ),
        ],
      );
    });

    testWidgets('renders correctly with all essential widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.text('New Article'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Add image'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Add Article'), findsOneWidget);
    });

    testWidgets('displays error when submitting without required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.tap(find.text('Add Article'));
      await tester.pump();

      expect(find.text('Required'), findsWidgets);
    });
  });
}