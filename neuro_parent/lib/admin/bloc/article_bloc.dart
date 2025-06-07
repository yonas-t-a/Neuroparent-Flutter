import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/article_repository.dart';
import '../../services/article_service.dart';
import '../../models/article.dart';
import 'dart:typed_data';

// States for Create Article
abstract class CreateArticleState {}

class CreateArticleInitial extends CreateArticleState {}

class CreateArticleLoading extends CreateArticleState {}

class CreateArticleSuccess extends CreateArticleState {
  final Article article;
  CreateArticleSuccess(this.article);
}

class CreateArticleError extends CreateArticleState {
  final String message;
  CreateArticleError(this.message);
}

class CreateArticleNotifier extends StateNotifier<CreateArticleState> {
  final ArticleRepository repository;
  CreateArticleNotifier({required this.repository})
    : super(CreateArticleInitial());

  Future<void> createArticle({
    required String title,
    required String content,
    required String category,
    required Uint8List imageBytes,
    required String filename,
    required String contentType,
  }) async {
    state = CreateArticleLoading();
    try {
      final article = await repository.createArticle(
        title: title,
        content: content,
        category: category,
        imageBytes: imageBytes,
        filename: filename,
        contentType: contentType,
      );
      state = CreateArticleSuccess(article);
    } catch (e) {
      state = CreateArticleError(e.toString());
    }
  }
}

final createArticleProvider = StateNotifierProvider.autoDispose.family<
  CreateArticleNotifier,
  CreateArticleState,
  String // jwtToken
>((ref, jwtToken) {
  final repository = ArticleRepository(
    articleService: ArticleService(jwtToken: jwtToken),
  );
  return CreateArticleNotifier(repository: repository);
});

// Providers for Article List and Filtering

// Fetches all articles
final articlesFutureProvider = FutureProvider.family.autoDispose<
  List<Article>,
  String // jwtToken
>((ref, jwtToken) async {
  final repository = ArticleRepository(
    articleService: ArticleService(jwtToken: jwtToken),
  );
  return repository.getArticles();
});

// State provider for the search query
final articleSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

// State provider for the selected category filter
final articleSelectedCategoryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

// Provider for the filtered list of articles
final filteredArticlesProvider = Provider.family.autoDispose<
  AsyncValue<List<Article>>,
  String // jwtToken
>((ref, jwtToken) {
  final articlesState = ref.watch(articlesFutureProvider(jwtToken));
  final searchQuery = ref.watch(articleSearchQueryProvider);
  final selectedCategory = ref.watch(articleSelectedCategoryProvider);

  return articlesState.when(
    data: (articles) {
      // Apply filtering
      final filtered =
          articles.where((article) {
            final matchesSearch =
                searchQuery.isEmpty ||
                article.articleTitle.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                article.articleContent.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );

            final matchesCategory =
                selectedCategory == null ||
                article.articleCategory == selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// States for Delete Article
abstract class DeleteArticleState {}

class DeleteArticleInitial extends DeleteArticleState {}

class DeleteArticleLoading extends DeleteArticleState {}

class DeleteArticleSuccess extends DeleteArticleState {
  final int articleId;
  DeleteArticleSuccess(this.articleId);
}

class DeleteArticleError extends DeleteArticleState {
  final String message;
  DeleteArticleError(this.message);
}

class DeleteArticleNotifier extends StateNotifier<DeleteArticleState> {
  final ArticleRepository repository;
  DeleteArticleNotifier({required this.repository})
    : super(DeleteArticleInitial());

  Future<void> deleteArticle(int articleId) async {
    state = DeleteArticleLoading();
    try {
      await repository.deleteArticle(articleId);
      state = DeleteArticleSuccess(articleId);
    } catch (e) {
      state = DeleteArticleError(e.toString());
    }
  }

  // Reset state after operation
  void resetState() {
    state = DeleteArticleInitial();
  }
}

final deleteArticleProvider = StateNotifierProvider.autoDispose.family<
  DeleteArticleNotifier,
  DeleteArticleState,
  String // jwtToken
>(
  (ref, jwtToken) => DeleteArticleNotifier(
    repository: ArticleRepository(
      articleService: ArticleService(jwtToken: jwtToken),
    ),
  ),
);

// States for Edit Article
abstract class EditArticleState {}

class EditArticleInitial extends EditArticleState {}

class EditArticleLoading extends EditArticleState {}

class EditArticleSuccess extends EditArticleState {
  final Article article;
  EditArticleSuccess(this.article);
}

class EditArticleError extends EditArticleState {
  final String message;
  EditArticleError(this.message);
}

class EditArticleNotifier extends StateNotifier<EditArticleState> {
  final ArticleRepository repository;
  EditArticleNotifier({required this.repository}) : super(EditArticleInitial());

  Future<void> updateArticle({
    required int id,
    String? title,
    String? content,
    String? category,
    Uint8List? imageBytes,
    String? filename,
    String? contentType,
  }) async {
    state = EditArticleLoading();
    try {
      final updatedArticle = await repository.updateArticle(
        id: id,
        title: title,
        content: content,
        category: category,
        imageBytes: imageBytes,
        filename: filename,
        contentType: contentType,
      );
      state = EditArticleSuccess(updatedArticle);
    } catch (e) {
      state = EditArticleError(e.toString());
    }
  }

  // Reset state after operation
  void resetState() {
    state = EditArticleInitial();
  }
}

final editArticleProvider = StateNotifierProvider.autoDispose.family<
  EditArticleNotifier,
  EditArticleState,
  String // jwtToken
>(
  (ref, jwtToken) => EditArticleNotifier(
    repository: ArticleRepository(
      articleService: ArticleService(jwtToken: jwtToken),
    ),
  ),
);
