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

class ArticleNotifier extends StateNotifier<ArticleState> {
  final ArticleRepository repository;
  ArticleNotifier(this.repository) : super(ArticleState());

  Future<void> fetchArticles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final articles = await repository.getArticles();
      state = state.copyWith(articles: articles, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
final userArticleProvider =
    StateNotifierProvider<ArticleNotifier, ArticleState>((ref) {
      final authState = ref.watch(authProvider);
      final token = authState is AuthSuccess ? authState.token : null;
      final repository = ArticleRepository(
        articleService: ArticleService(jwtToken: token),
      );
      return ArticleNotifier(repository);
    });