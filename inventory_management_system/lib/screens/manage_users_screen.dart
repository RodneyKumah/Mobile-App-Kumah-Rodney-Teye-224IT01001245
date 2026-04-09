import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/confirm_dialog.dart';

class ManageUsersScreen extends StatefulWidget {
  final String currentUsername;
  const ManageUsersScreen({super.key, required this.currentUsername});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  // Add user form
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure    = true;
  bool _isAdding   = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final users = await DatabaseHelper.instance.getAllUsers();
    setState(() { _users = users; _isLoading = false; });
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isAdding = true);

    final success = await DatabaseHelper.instance.addUser(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (success) {
      _usernameController.clear();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User added successfully.'),
        backgroundColor: AppTheme.success,
      ));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Username already exists.'),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  Future<void> _deleteUser(User user) async {
    if (user.username == widget.currentUsername) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You cannot delete your own account.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete User',
      message: 'Remove "${user.username}"? They will no longer be able to log in.',
      confirmLabel: 'Delete',
    );

    if (confirmed) {
      await DatabaseHelper.instance.deleteUser(user.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Add user form ─────────────────────────────────────
            const Text('Add New User',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Username is required';
                          }
                          if (v.trim().length < 3) {
                            return 'At least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (v.trim().length < 6) {
                            return 'At least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isAdding
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.person_add),
                          label: const Text('Add User'),
                          onPressed: _isAdding ? null : _addUser,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── User list ─────────────────────────────────────────
            Row(
              children: [
                const Text('Existing Users',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${_users.length}',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ...(_users.map((user) {
                final isSelf = user.username == widget.currentUsername;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelf
                          ? AppTheme.primary
                          : Colors.grey.shade200,
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: TextStyle(
                            color:
                                isSelf ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(user.username),
                        if (isSelf) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('You',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: const Text('Authorized user'),
                    trailing: isSelf
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppTheme.danger),
                            onPressed: () => _deleteUser(user),
                          ),
                  ),
                );
              })),
          ],
        ),
      ),
    );
  }
}
