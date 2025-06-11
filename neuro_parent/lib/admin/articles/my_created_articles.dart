import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/bloc/article_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:mime_type/mime_type.dart';
import '../../models/article.dart'; 
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart'; 
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:collection/collection.dart';

class MyCreatedArticlesPage extends ConsumerStatefulWidget {
  final String jwtToken;
  final int articleId; 

  const MyCreatedArticlesPage({
    super.key,
    required this.jwtToken,
    required this.articleId,
  });

  @override
  ConsumerState<MyCreatedArticlesPage> createState() =>
      _MyCreatedArticlesPageState();
}

class _MyCreatedArticlesPageState extends ConsumerState<MyCreatedArticlesPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _selectedCategory;
  File?
  _selectedImage; 
  bool _submitted = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageFilename;
  bool _isImageNew = false; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = File(pickedFile.path); 
        _selectedImageBytes = bytes;
        _selectedImageFilename = pickedFile.name;
        _isImageNew = true;
      });
    }
  }

  void _submit({required Article articleToUpdate}) async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    String? contentType;
    if (_isImageNew) {
      contentType = mime(_selectedImageFilename!);
    }

    final notifier = ref.read(editArticleProvider(widget.jwtToken).notifier);

    await notifier.updateArticle(
      id: articleToUpdate.articleId!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory!,
      imageBytes: _selectedImageBytes,
      filename: _selectedImageFilename, 
      contentType: contentType, 
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editArticleProvider(widget.jwtToken));
    final articlesAsyncValue = ref.watch(
      articlesFutureProvider(widget.jwtToken),
    );

    return articlesAsyncValue.when(
      data: (articles) {
        final article = articles.firstWhereOrNull(
          (a) => a.articleId == widget.articleId,
        );

        if (article == null) {
          return const Scaffold(
            body: Center(child: Text('Article not found.')),
          );
        }
        if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
          _titleController.text = article.articleTitle;
          _contentController.text = article.articleContent;
          _selectedCategory = article.articleCategory;
        }

        ref.listen<EditArticleState>(editArticleProvider(widget.jwtToken), (
          previous,
          next,
        ) {
          if (next is EditArticleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Article updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            ref.invalidate(articlesFutureProvider(widget.jwtToken));
            context.pop(); 
          } else if (next is EditArticleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update article: ${next.message}'),
              ),
            );
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => context.go('/admin/add'),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Edit Article',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Title'),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _titleController,
                      validator:
                          (v) => v == null || v.isEmpty ? 'Required' : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Image'), 
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Row(
                        children: [
                          _selectedImageBytes != null
                              ? CircleAvatar(
                                radius: 25,
                                backgroundImage: MemoryImage(
                                  _selectedImageBytes!,
                                ),
                              ) 
                              : (article.articleImage.isNotEmpty
                                  ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage: CachedNetworkImageProvider(
                                      article.articleImage,
                                    ),
                                  ) 
                                  : CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.article,
                                      color: Colors.grey[600],
                                    ),
                                  )),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                _selectedImageBytes != null
                                    ? _selectedImageFilename ??
                                        "New image selected"
                                    : (article.articleImage.isNotEmpty
                                        ? "Existing image"
                                        : "Upload new image"),
                                style: TextStyle(
                                  color:
                                      _selectedImageBytes != null ||
                                              article.articleImage.isNotEmpty
                                          ? Colors.black
                                          : (_submitted
                                              ? Colors.red
                                              : Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          if (!_isImageNew &&
                              article
                                  .articleImage
                                  .isNotEmpty) 
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Image removal not directly supported. Upload a new image to replace.',
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category'),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Category",
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          [
                                'ASD',
                                'ADHD',
                                'Dyslexia',
                                'Dyscalculia',
                                'Dyspraxia',
                                'Tourette Syndrome',
                                'OCD',
                                'Bipolar',
                                'Anxiety',
                              ]
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedCategory = value),
                      validator:
                          (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 4),
                    const Text('Content'),
                    const SizedBox(height: 4),
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blue.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child:
                          state is EditArticleLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                onPressed:
                                    () => _submit(articleToUpdate: article),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Update Article'),
                              ),
                    ),
                    if (state is EditArticleError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (state is EditArticleSuccess)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Article updated successfully!',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: UserBottomNav(
            currentIndex: _getCurrentIndex(context),
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.blue[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
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
