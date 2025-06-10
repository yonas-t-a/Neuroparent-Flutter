import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/admin/bloc/article_bloc.dart';
import 'package:neuro_parent/models/article.dart';
import 'package:neuro_parent/repositories/article_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:typed_data';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  late MockArticleRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleRepository();
  });

  group('CreateArticleNotifier', () {
    late CreateArticleNotifier createArticleNotifier;

    setUp(() {
      createArticleNotifier = CreateArticleNotifier(repository: mockRepository);
    });

    test('emits [CreateArticleLoading, CreateArticleSuccess] on successful article creation', () async {
      final article = Article(
        articleId: 1,
        articleTitle: 'Test Article',
        articleContent: 'This is a test article.',
        articleCategory: 'Test Category',
        articleImage: 'test_image_url',
        articleCreatorId: 101,
      );

      when(() => mockRepository.createArticle(
            title: 'Test Article',
            content: 'This is a test article.',
            category: 'Test Category',
            imageBytes: Uint8List(0),
            filename: 'test_image.jpg',
            contentType: 'image/jpeg',
          )).thenAnswer((_) async => article);

      expectLater(
        createArticleNotifier.stream,
        emitsInOrder([
          isA<CreateArticleLoading>(),
          isA<CreateArticleSuccess>(),
        ]),
      );

      await createArticleNotifier.createArticle(
        title: 'Test Article',
        content: 'This is a test article.',
        category: 'Test Category',
        imageBytes: Uint8List(0),
        filename: 'test_image.jpg',
        contentType: 'image/jpeg',
      );
    });

    test('emits [CreateArticleLoading, CreateArticleError] on article creation failure', () async {
      when(() => mockRepository.createArticle(
            title: 'Test Article',
            content: 'This is a test article.',
            category: 'Test Category',
            imageBytes: Uint8List(0),
            filename: 'test_image.jpg',
            contentType: 'image/jpeg',
          )).thenThrow(Exception('Failed to create article'));

      expectLater(
        createArticleNotifier.stream,
        emitsInOrder([
          isA<CreateArticleLoading>(),
          isA<CreateArticleError>(),
        ]),
      );

      await createArticleNotifier.createArticle(
        title: 'Test Article',
        content: 'This is a test article.',
        category: 'Test Category',
        imageBytes: Uint8List(0),
        filename: 'test_image.jpg',
        contentType: 'image/jpeg',
      );
    });
  });

  group('DeleteArticleNotifier', () {
    late DeleteArticleNotifier deleteArticleNotifier;

    setUp(() {
      deleteArticleNotifier = DeleteArticleNotifier(repository: mockRepository);
    });

    test('emits [DeleteArticleLoading, DeleteArticleSuccess] on successful article deletion', () async {
      when(() => mockRepository.deleteArticle(1)).thenAnswer((_) async => Future.value());

      expectLater(
        deleteArticleNotifier.stream,
        emitsInOrder([
          isA<DeleteArticleLoading>(),
          isA<DeleteArticleSuccess>(),
        ]),
      );

      await deleteArticleNotifier.deleteArticle(1);
    });

    test('emits [DeleteArticleLoading, DeleteArticleError] on article deletion failure', () async {
      when(() => mockRepository.deleteArticle(1)).thenThrow(Exception('Failed to delete article'));

      expectLater(
        deleteArticleNotifier.stream,
        emitsInOrder([
          isA<DeleteArticleLoading>(),
          isA<DeleteArticleError>(),
        ]),
      );

      await deleteArticleNotifier.deleteArticle(1);
    });
  });
}