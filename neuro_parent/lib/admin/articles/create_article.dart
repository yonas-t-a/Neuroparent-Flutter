import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/bloc/article_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:mime_type/mime_type.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';


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
