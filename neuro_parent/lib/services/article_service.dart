import 'package:dio/dio.dart';
import '../models/article.dart';
import 'package:flutter/foundation.dart'; // Import for Uint8List
import 'package:http_parser/http_parser.dart'; // Import for MediaType

class ArticleService {
  static const String baseUrl = 'http://10.0.2.2:3500/api/articles';
  final Dio _dio;

  ArticleService({String? jwtToken, Dio? dio})
    : _dio = dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {
                'Content-Type': 'application/json',
                if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
              },
            ),
          );

  Future<List<Article>> getArticles() async {
    final response = await _dio.get('/');
    final data = response.data['data'] as List;
    return data.map((e) => Article.fromJson(e)).toList();
  }

  Future<Article> getArticleById(int id) async {
    final response = await _dio.get('/$id');
    return Article.fromJson(response.data['data']);
  }

  Future<List<Article>> getArticlesByCategory(String category) async {
    final response = await _dio.get('/category/$category');
    final data = response.data['data'] as List;
    return data.map((e) => Article.fromJson(e)).toList();
  }

  Future<Article> createArticle({
    required String title,
    required String content,
    required String category,
    required Uint8List imageBytes,
    required String filename,
    required String contentType,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'content': content,
      'category': category,
      'img': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ),
    });
    final response = await _dio.post('/', data: formData);
    return Article.fromJson(response.data['data']);
  }

  Future<Article> updateArticle({
    required int id,
    String? title,
    String? content,
    String? category,
    Uint8List? imageBytes,
    String? filename,
    String? contentType,
  }) async {
    final formData = FormData();
    if (title != null) formData.fields.add(MapEntry('title', title));
    if (content != null) formData.fields.add(MapEntry('content', content));
    if (category != null) formData.fields.add(MapEntry('category', category));
    if (imageBytes != null && filename != null && contentType != null) {
      formData.files.add(
        MapEntry(
          'img',
          MultipartFile.fromBytes(
            imageBytes,
            filename: filename,
            contentType: MediaType.parse(contentType),
          ),
        ),
      );
    }
    final response = await _dio.patch('/$id', data: formData);
    return Article.fromJson(response.data['data']);
  }

  Future<void> deleteArticle(int id) async {
    await _dio.delete('/$id');
  }
}
