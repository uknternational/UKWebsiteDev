import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_auth_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showForgotPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminAuthBloc>().add(
        AdminSignInRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  void _onForgotPassword() {
    if (_emailController.text.trim().isNotEmpty) {
      context.read<AdminAuthBloc>().add(
        AdminForgotPasswordRequested(_emailController.text.trim()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email to reset password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: const Color(0xFF0C1B33),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AdminAuthBloc, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login failed: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AdminForgotPasswordEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminAuthSuccess) {
            context.go('/admin/dashboard');
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and title
                        Image.asset('assets/logo.png', height: 60),
                        const SizedBox(height: 16),
                        const Text(
                          'Admin Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C1B33),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value != null && value.contains('@')
                              ? null
                              : 'Enter a valid email',
                        ),
                        const SizedBox(height: 16),
                        if (!_showForgotPassword)
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value != null && value.length >= 6
                                ? null
                                : 'Password must be at least 6 characters',
                          ),
                        const SizedBox(height: 16),
                        if (state is AdminAuthLoading)
                          const CircularProgressIndicator()
                        else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _showForgotPassword
                                  ? _onForgotPassword
                                  : _onLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C1B33),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _showForgotPassword
                                    ? 'Send Reset Email'
                                    : 'Login',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(
                              () => _showForgotPassword = !_showForgotPassword,
                            ),
                            child: Text(
                              _showForgotPassword
                                  ? 'Back to Login'
                                  : 'Forgot Password?',
                              style: const TextStyle(color: Color(0xFF0C1B33)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
