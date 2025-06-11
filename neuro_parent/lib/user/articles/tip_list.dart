import 'package:flutter/material.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_article_bloc.dart';
import 'package:neuro_parent/core/categories.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(userArticleProvider.notifier).fetchArticles(),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/registered')) return 2;
    if (location.startsWith('/articles')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }
  @override
  Widget build(BuildContext context) {
    final articleState = ref.watch(userArticleProvider);
    final articles = articleState.articles;
    final isLoading = articleState.isLoading;
    final error = articleState.error;

    // Get unique categories
    final categories = [
      ...{for (final a in Categories.allCategories) a},
    ];

    // Filtered articles
    final filteredArticles =
        articles.where((article) {
          final matchesSearch = article.articleTitle.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              _selectedCategory == 'ALL' ||
              article.articleCategory == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();
