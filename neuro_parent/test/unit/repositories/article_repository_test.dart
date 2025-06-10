import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'package:neuro_parent/services/article_service.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:typed_data';

class MockArticleService extends Mock implements ArticleService {}

void main() {
  late ArticleRepository articleRepository;
  late MockArticleService mockArticleService;

  setUp(() {
    mockArticleService = MockArticleService();
    articleRepository = ArticleRepository(articleService: mockArticleService);
  });

  group('ArticleRepository', () {
    final articleJson = {
      'article_id': 1,
      'article_title': 'Test Article',
      'article_content': 'This is a test article.',
      'article_category': 'Test Category',
      'article_image': 'test_image_url',
      'article_creator_id': 101,
    };

    final article = Article.fromJson(articleJson);

    test('getArticles returns a list of articles', () async {
      when(() => mockArticleService.getArticles())
          .thenAnswer((_) async => [article]);

      final result = await articleRepository.getArticles();

      expect(result, isA<List<Article>>());
      expect(result.length, 1);
      expect(result.first.articleTitle, 'Test Article');
    });

    test('getArticleById returns a single article', () async {
      when(() => mockArticleService.getArticleById(1))
          .thenAnswer((_) async => article);

      final result = await articleRepository.getArticleById(1);

      expect(result, isA<Article>());
      expect(result.articleTitle, 'Test Article');
    });

    test('getArticlesByCategory returns articles filtered by category', () async {
      when(() => mockArticleService.getArticlesByCategory('Test Category'))
          .thenAnswer((_) async => [article]);

      final result = await articleRepository.getArticlesByCategory('Test Category');

      expect(result, isA<List<Article>>());
      expect(result.first.articleCategory, 'Test Category');
    });

    test('createArticle returns the created article', () async {
      when(() => mockArticleService.createArticle(
            title: 'Test Article',
            content: 'This is a test article.',
            category: 'Test Category',
            imageBytes: Uint8List(0),
            filename: 'test_image.jpg',
            contentType: 'image/jpeg',
          )).thenAnswer((_) async => article);

      final result = await articleRepository.createArticle(
        title: 'Test Article',
        content: 'This is a test article.',
        category: 'Test Category',
        imageBytes: Uint8List(0),
        filename: 'test_image.jpg',
        contentType: 'image/jpeg',
      );

      expect(result, isA<Article>());
      expect(result.articleTitle, 'Test Article');
    });

    test('updateArticle returns the updated article', () async {
      when(() => mockArticleService.updateArticle(
            id: 1,
            title: 'Updated Article',
            content: 'Updated content.',
          )).thenAnswer((_) async => article);

      final result = await articleRepository.updateArticle(
        id: 1,
        title: 'Updated Article',
        content: 'Updated content.',
      );

      expect(result, isA<Article>());
      expect(result.articleTitle, 'Test Article'); // Assuming backend returns the original title
    });

    test('deleteArticle completes successfully', () async {
      when(() => mockArticleService.deleteArticle(1))
          .thenAnswer((_) async => Future.value());

      await articleRepository.deleteArticle(1);

      verify(() => mockArticleService.deleteArticle(1)).called(1);
    });
  });
}