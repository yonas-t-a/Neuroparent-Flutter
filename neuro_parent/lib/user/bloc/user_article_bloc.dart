import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/article.dart';
import '../../repositories/article_repository.dart';
import '../../services/article_service.dart';
import '../../auth/auth_bloc.dart';

class ArticleState {
  final List<Article> articles;
  final bool isLoading;
  final String? error;

  ArticleState({this.articles = const [], this.isLoading = false, this.error});

  ArticleState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? error,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}