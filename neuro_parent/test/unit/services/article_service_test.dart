import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/services/article_service.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ArticleService articleService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    articleService = ArticleService(jwtToken: 'test_token', dio: mockDio); 
  });

  group('ArticleService', () {
    final articleJson = {
      'article_id': 1,
      'article_title': 'Test Article',
      'article_content': 'This is a test article.',
      'article_category': 'Test Category',
      'article_image': 'test_image_url',
      'article_creator_id': 101,
    };

    test('getArticles returns a list of articles', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/'),
        data: {'data': [articleJson]},
        statusCode: 200,
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await articleService.getArticles();

      expect(result, isA<List<Article>>());
      expect(result.length, 1);
      expect(result.first.articleTitle, 'Test Article');
    });

    test('getArticleById returns a single article', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/1'),
        data: {'data': articleJson},
        statusCode: 200,
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await articleService.getArticleById(1);

      expect(result, isA<Article>());
      expect(result.articleTitle, 'Test Article');
    });

    test('getArticlesByCategory returns articles filtered by category', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/category/Test Category'),
        data: {'data': [articleJson]},
        statusCode: 200,
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await articleService.getArticlesByCategory('Test Category');

      expect(result, isA<List<Article>>());
      expect(result.first.articleCategory, 'Test Category');
    });

    test('createArticle returns the created article', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/'),
        data: {'data': articleJson},
        statusCode: 201,
      );
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final result = await articleService.createArticle(
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
      final response = Response(
        requestOptions: RequestOptions(path: '/1'),
        data: {'data': articleJson},
        statusCode: 200,
      );
      when(() => mockDio.patch(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final result = await articleService.updateArticle(
        id: 1,
        title: 'Updated Article',
        content: 'Updated content.',
      );

      expect(result, isA<Article>());
      expect(result.articleTitle, 'Test Article'); 
    });

    test('deleteArticle completes successfully', () async {
      when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/1'),
            statusCode: 204,
          ));

      await articleService.deleteArticle(1);

      verify(() => mockDio.delete('/1')).called(1);
    });
  });
}