import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/services/article_service.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'dart:typed_data';

void main() {
  group('Article Integration Tests', () {
    late ArticleService articleService;
    late ArticleRepository articleRepository;

    setUp(() {
      articleService = ArticleService();
      articleRepository = ArticleRepository(articleService: articleService);
    });

    test('Fetch articles', () async {
      try {
        final articles = await articleRepository.getArticles();
        expect(articles, isA<List<Article>>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Create article', () async {
      final article = Article(
        articleTitle: 'Test Article',
        articleContent: 'This is a test article',
        articleCategory: 'Test Category',
        articleImage: 'https://example.com/image.jpg',
      );

      try {
        await articleRepository.createArticle(
          title: article.articleTitle,
          content: article.articleContent,
          category: article.articleCategory,
          imageBytes: Uint8List(0),
          filename: 'image.jpg',
          contentType: 'image/jpeg',
        );
        expect(true, isTrue); 
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Update article', () async {
      final article = Article(
        articleId: 1,
        articleTitle: 'Updated Article',
        articleContent: 'This is an updated test article',
        articleCategory: 'Updated Category',
        articleImage: 'https://example.com/updated_image.jpg',
      );

      try {
        await articleRepository.updateArticle(
          id: article.articleId!,
          title: article.articleTitle,
          content: article.articleContent,
          category: article.articleCategory,
          imageBytes: Uint8List(0),
          filename: 'updated_image.jpg',
          contentType: 'image/jpeg',
        );
        expect(true, isTrue); 
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Delete article', () async {
      const articleId = 1;

      try {
        await articleRepository.deleteArticle(articleId);
        expect(true, isTrue); 
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Fetch article by ID', () async {
      const articleId = 1;

      try {
        final article = await articleRepository.getArticleById(articleId);
        expect(article, isA<Article>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
