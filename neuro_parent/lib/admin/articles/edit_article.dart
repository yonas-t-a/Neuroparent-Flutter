import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/bloc/article_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';

class EditArticlePage extends ConsumerStatefulWidget {
  final String jwtToken;
  const EditArticlePage({super.key, required this.jwtToken});

  @override
  ConsumerState<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends ConsumerState<EditArticlePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'All', // Add 'All' option for category filter
    'ASD',
    'ADHD',
    'Dyslexia',
    'Dyscalculia',
    'Dyspraxia',
    'Tourette Syndrome',
    'OCD',
    'Bipolar',
    'Anxiety',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int articleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this article?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      ref
          .read(deleteArticleProvider(widget.jwtToken).notifier)
          .deleteArticle(articleId);
    }
  }

  void _handleDeleteError(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state of the delete operation for feedback
    ref.listen<DeleteArticleState>(deleteArticleProvider(widget.jwtToken), (
      previous,
      next,
    ) {
      if (next is DeleteArticleSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Article ${next.articleId} deleted successfully!'),
          ),
        );
        // Invalidate the articles provider to refresh the list
        ref.invalidate(articlesFutureProvider(widget.jwtToken));
      } else if (next is DeleteArticleError) {
        _handleDeleteError(
          context,
          'Failed to delete article: ${next.message}',
        );
      }
    });

    final filteredArticlesState = ref.watch(
      filteredArticlesProvider(widget.jwtToken),
    );
    final selectedCategory = ref.watch(articleSelectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tips & Tricks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin/add');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  ref.read(articleSearchQueryProvider.notifier).state = query;
                },
                decoration: InputDecoration(
                  hintText: "Search tips",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories
                        .map(
                          (category) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: ChoiceChip(
                              label: Text(category),
                              selected:
                                  selectedCategory == category ||
                                  (selectedCategory == null &&
                                      category == 'All'),
                              onSelected: (selected) {
                                if (selected) {
                                  ref
                                          .read(
                                            articleSelectedCategoryProvider
                                                .notifier,
                                          )
                                          .state =
                                      category == 'All' ? null : category;
                                } else if (selectedCategory == category) {
                                  // This case handles deselecting the current chip,
                                  // effectively setting the filter back to 'All'.
                                  ref
                                      .read(
                                        articleSelectedCategoryProvider
                                            .notifier,
                                      )
                                      .state = null;
                                }
                              },
                              selectedColor: Colors.blue.shade100,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Articles List
            filteredArticlesState.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return const Expanded(
                    child: Center(child: Text('No articles found.')),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      // Check if articleId is not null before displaying delete button
                      if (article.articleId == null) return SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(image, column(title, subtitle))
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Assuming article_image is a URL
                                  article.articleImage.isNotEmpty
                                      ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          article.articleImage,
                                        ),
                                        backgroundColor: Colors.grey.shade200,
                                      )
                                      : CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.article,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.articleTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          article.articleCategory,
                                        ), // Display category as subtitle
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row(delete button, edit button)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          () => _confirmDelete(
                                            article.articleId!,
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade300,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        minimumSize: Size(double.infinity, 35),
                                      ),
                                      child: const Text(
                                        "Delete Article",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go(
                                        '/admin/edit-article/${article.articleId}',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade300,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading:
                  () => const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, stack) => Expanded(
                    child: Center(child: Text('Error: ${error.toString()}')),
                  ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context),
      ),
    );
  }
}

int _getCurrentIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/events')) return 1;
  if (location.startsWith('/registered')) return 2;
  if (location.startsWith('/articles')) return 3;
  if (location.startsWith('/profile')) return 4;
  if (location.startsWith('/admin/add')) return 5;
  return 0;
}
