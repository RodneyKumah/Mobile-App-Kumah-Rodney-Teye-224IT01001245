import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    final user = await DatabaseHelper.instance
        .login(_usernameController.text, _passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => DashboardScreen(username: user.username)));
    } else {
      setState(() => _errorMessage = 'Incorrect username or password.');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.primary),
                    const SizedBox(height: 8),
                    const Text(AppConstants.appName,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 28),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorMessage!,
                              style: const TextStyle(color: AppTheme.danger))),
                        ]),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => Validators.required(v, 'Username'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => Validators.required(v, 'Password'),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('Login', style: TextStyle(fontSize: 16))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Default: admin / admin123',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
