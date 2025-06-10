import '../services/article_service.dart';
import '../models/article.dart';
import 'dart:typed_data'; // Import Uint8List

class ArticleRepository {
  final ArticleService articleService;

  ArticleRepository({required this.articleService});

  Future<List<Article>> getArticles() => articleService.getArticles();
  Future<Article> getArticleById(int id) => articleService.getArticleById(id);
  Future<List<Article>> getArticlesByCategory(String category) =>
      articleService.getArticlesByCategory(category);
  Future<Article> createArticle({
    required String title,
    required String content,
    required String category,
    required Uint8List imageBytes,
    required String filename,
    required String contentType,
  }) => articleService.createArticle(
    title: title,
    content: content,
    category: category,
    imageBytes: imageBytes,
    filename: filename,
    contentType: contentType,
  );
  Future<Article> updateArticle({
    required int id,
    String? title,
    String? content,
    String? category,
    Uint8List? imageBytes,
    String? filename,
    String? contentType,
  }) => articleService.updateArticle(
    id: id,
    title: title,
    content: content,
    category: category,
    imageBytes: imageBytes,
    filename: filename,
    contentType: contentType,
  );
  Future<void> deleteArticle(int id) => articleService.deleteArticle(id);
}
