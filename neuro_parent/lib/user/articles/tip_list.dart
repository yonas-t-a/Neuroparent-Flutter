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
  return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/home'),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Tips & Tricks',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search tips',
                        filled: true,
                        fillColor: Color(0xFFF3F6FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              SizedBox(
                height: 40.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final category in categories) ...[
                      _buildCategoryChip(category),
                    const SizedBox(width: 8.0),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Popular Tips',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12.0),
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (error != null)
                Expanded(child: Center(child: Text('Error: $error'))),
              if (!isLoading && error == null)
              Expanded(
                  child:
                      filteredArticles.isEmpty
                          ? const Center(child: Text('No articles found.'))
                          : ListView.builder(
                            itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                              final article = filteredArticles[index];
                              final subtitle =
                                  article.articleContent
                                      .split(' ')
                                      .take(10)
                                      .join(' ') +
                                  (article.articleContent.split(' ').length > 10
                                      ? '...'
                                      : '');
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1.0,
                                  ),
                                ),
                                margin: const EdgeInsets.only(bottom: 16.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16.0),
                                  leading:
                                      article.articleImage.isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            child: Image.network(
                                              article.articleImage,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE3F2FD),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: const Icon(
                                              Icons.article,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                  title: Text(
                                    article.articleTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  subtitle: Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    context.go(
                                      '/articles/${article.articleId}',
                                    );
                                  },
                                ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context),
      ),
    );
  }
