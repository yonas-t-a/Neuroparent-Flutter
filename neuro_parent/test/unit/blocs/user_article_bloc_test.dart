import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/user/bloc/user_article_bloc.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepository;
  late ArticleNotifier articleNotifier;

  setUp(() {
    mockRepository = MockArticleRepository();
    articleNotifier = ArticleNotifier(mockRepository);
  });

  group('ArticleNotifier', () {
    final article = Article(
      articleId: 1,
      articleTitle: 'Test Article',
      articleContent: 'This is a test article.',
      articleCategory: 'Test Category',
      articleImage: 'test_image_url',
      articleCreatorId: 101,
    );

    test('emits loading and success states on successful fetchArticles', () async {
      when(() => mockRepository.getArticles()).thenAnswer((_) async => [article]);

      expectLater(
        articleNotifier.stream,
        emitsInOrder([
          isA<ArticleState>().having((state) => state.isLoading, 'isLoading', true),
          isA<ArticleState>().having((state) => state.articles, 'articles', [article]),
        ]),
      );

      await articleNotifier.fetchArticles();
    });

    test('emits loading and error states on fetchArticles failure', () async {
      when(() => mockRepository.getArticles()).thenThrow(Exception('Failed to fetch articles'));

      expectLater(
        articleNotifier.stream,
        emitsInOrder([
          isA<ArticleState>().having((state) => state.isLoading, 'isLoading', true),
          isA<ArticleState>().having((state) => state.error, 'error', 'Exception: Failed to fetch articles'),
        ]),
      );

      await articleNotifier.fetchArticles();
    });
  });
}