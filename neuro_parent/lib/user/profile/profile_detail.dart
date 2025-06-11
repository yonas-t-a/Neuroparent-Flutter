import 'package:flutter/material.dart';
import 'package:neuro_parent/user/widgets/user_bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/user_profile_bloc.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    Future.microtask(() => ref.read(userProfileProvider.notifier).fetchUser());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProfileNotifier = ref.read(userProfileProvider.notifier);
    final userProfileState = ref.read(userProfileProvider);

    if (userProfileState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update: User data not loaded.')),
      );
      return;
    }

    final String oldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;

    // Check if any fields are actually being updated (name or new password)
    bool isNameChanged =
        _nameController.text.trim() != userProfileState.user!.name;
    bool isPasswordChanged = newPassword.isNotEmpty;

    // If no changes are made and old password is not provided, do nothing or inform user
    if (!isNameChanged && !isPasswordChanged && oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to update or old password not provided.'),
        ),
      );
      return;
    }

    // If any change is attempted, old password is required for confirmation
    if (oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your old password to confirm changes.'),
        ),
      );
      return;
    }

    // Now handle the password update logic if newPassword is provided
    String? finalNewPassword;
    if (newPassword.isNotEmpty) {
      finalNewPassword = newPassword;
    }

    await userProfileNotifier.updateUser(
      name: isNameChanged ? _nameController.text.trim() : null,
      email: userProfileState.user!.email,
      oldPassword: oldPassword,
      newPassword: finalNewPassword,
    );

    // Check if the widget is still mounted before using context
    if (!mounted) return;

    // After the update, check the latest state to determine success or failure
    final updatedUserProfileState = ref.read(userProfileProvider);

    if (updatedUserProfileState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: ${updatedUserProfileState.error}'),
        ),
      );
    } else if (updatedUserProfileState.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ), // Ensure this message is visible
      );
      context.go('/profile'); // Navigate back to the profile page on success
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileState = ref.watch(userProfileProvider);

    if (userProfileState.user != null && _nameController.text.isEmpty) {
      _nameController.text = userProfileState.user!.name;
      _emailController.text = userProfileState.user!.email;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body:
          userProfileState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : userProfileState.error != null
              ? Center(child: Text('Error: ${userProfileState.error}'))
              : userProfileState.user == null
              ? const Center(child: Text('No user data available.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        userProfileState.user?.name ?? 'NeuroParent',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          filled: true,
                          fillColor: const Color(0xFFF3F6FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: !_isNewPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          filled: true,
                          fillColor: const Color(0xFFF3F6FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isNewPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          // This validator is now handled by the _submitUpdate logic
                          return null;
                        },
                      ),
                      const SizedBox(height: 65),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: !_isOldPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Confirm with Old Password",
                          filled: true,
                          fillColor: const Color(0xFFF3F6FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isOldPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isOldPasswordVisible = !_isOldPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          filled: true,
                          fillColor: const Color(0xFFF3F6FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              userProfileState.isLoading ? null : _submitUpdate,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFD67E7E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: Size(double.infinity, 48),
                          ),
                          child:
                              userProfileState.isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: _getCurrentIndex(context) - 1,
      ),
    );
  }
}

int _getCurrentIndex(BuildContext context) {
  return 4;
}
