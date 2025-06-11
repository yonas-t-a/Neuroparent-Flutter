import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/bloc/article_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:mime_type/mime_type.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';

class CreateArticlePage extends ConsumerStatefulWidget {
  final String jwtToken;
  const CreateArticlePage({super.key, required this.jwtToken});

  @override
  ConsumerState<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends ConsumerState<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedCategory;
  File?
  _selectedImage; 
  bool _submitted = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageFilename;

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
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() ||
        _selectedImageBytes == null ||
        _selectedImageFilename == null) {
      return;
    }

    final String? contentType = mime(_selectedImageFilename!);
    if (contentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine image type.')),
      );
      return;
    }

    final notifier = ref.read(createArticleProvider(widget.jwtToken).notifier);
    await notifier.createArticle(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory!,
      imageBytes: _selectedImageBytes!,
      filename: _selectedImageFilename!,
      contentType: contentType,
    );
  }


@override
  Widget build(BuildContext context) {
    final state = ref.watch(createArticleProvider(widget.jwtToken));
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
                      onPressed: () {
                        context.go('/admin/add');
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Preview',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'New Article',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Title'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _titleController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                const Text('Add image'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _pickImage,
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.upload, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            _selectedImageBytes != null
                                ? _selectedImageFilename ?? "Image selected"
                                : (_submitted
                                    ? 'Image required'
                                    : 'Upload image'),
                            style: TextStyle(
                              color:
                                  _selectedImageBytes != null
                                      ? Colors.black
                                      : (_submitted ? Colors.red : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Category'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration("Category"),
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
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
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
                      state is CreateArticleLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: _submit,
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
                            child: const Text('Add Article'),
                          ),
                ),
                if (state is CreateArticleError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      (state).message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (state is CreateArticleSuccess)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Article created successfully!',
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
