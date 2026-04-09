import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class SettingsScreen extends StatefulWidget {
  final String username;
  const SettingsScreen({super.key, required this.username});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Change password form
  final _pwFormKey = GlobalKey<FormState>();
  final _oldPwController  = TextEditingController();
  final _newPwController  = TextEditingController();
  final _confPwController = TextEditingController();
  bool _obscureOld  = true;
  bool _obscureNew  = true;
  bool _obscureConf = true;
  bool _isSaving    = false;

  @override
  void dispose() {
    _oldPwController.dispose();
    _newPwController.dispose();
    _confPwController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final success = await DatabaseHelper.instance.changePassword(
      widget.username,
      _oldPwController.text.trim(),
      _newPwController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _oldPwController.clear();
      _newPwController.clear();
      _confPwController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password changed successfully.'),
        backgroundColor: AppTheme.success,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Current password is incorrect.'),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Account info ──────────────────────────────────────
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(widget.username,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Logged in user'),
              ),
            ),
            const SizedBox(height: 24),

            // ── Change password ───────────────────────────────────
            const Text('Change Password',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _pwFormKey,
                  child: Column(
                    children: [
                      _PwField(
                        controller: _oldPwController,
                        label: 'Current Password',
                        obscure: _obscureOld,
                        onToggle: () =>
                            setState(() => _obscureOld = !_obscureOld),
                        validator: (v) => Validators.required(v, 'Current password'),
                      ),
                      const SizedBox(height: 14),
                      _PwField(
                        controller: _newPwController,
                        label: 'New Password',
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'New password is required';
                          }
                          if (v.trim().length < 6) {
                            return 'Must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _PwField(
                        controller: _confPwController,
                        label: 'Confirm New Password',
                        obscure: _obscureConf,
                        onToggle: () =>
                            setState(() => _obscureConf = !_obscureConf),
                        validator: (v) {
                          if (v != _newPwController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.lock_reset),
                          label: const Text('Update Password'),
                          onPressed: _isSaving ? null : _changePassword,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── App info ──────────────────────────────────────────
            const Text('About',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _InfoTile('App Name',    AppConstants.appName),
                  _InfoTile('Version',     '1.0.0'),
                  _InfoTile('Currency',    AppConstants.currency),
                  _InfoTile('Low Stock Alert', 'Below ${AppConstants.lowStockThreshold} units'),
                  _InfoTile('Database',    'SQLite (local)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PwField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      trailing:
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
