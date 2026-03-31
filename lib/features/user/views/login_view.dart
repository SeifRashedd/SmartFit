import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/user/views/register_view.dart';
import 'package:smartfit/features/user/widgets/auth_header_widget.dart';
import 'package:smartfit/features/user/widgets/auth_text_form_field.dart';
import 'package:smartfit/features/user/validators/auth_validators.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    // Intentionally no backend action for now.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.appPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const AuthHeader(title: 'Welcome Back', subtitle: 'Sign in to continue your SmartFit journey.'),
                const SizedBox(height: 28),
                AuthTextFormField(
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined),
                  controller: _emailController,
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 14),
                AuthTextFormField(
                  hintText: 'Password',
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline_rounded),
                  controller: _passwordController,
                  validator: AuthValidators.password,
                ),
                const SizedBox(height: 22),
                CustomButton(
                  onPressed: _onLoginPressed,
                  text: 'Login',
                  showIcon: true,
                  icon: const Icon(Icons.login_rounded, size: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account? ', style: AppFonts.montserrat14Regular64748B),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterView()));
                      },
                      child: Text('Register', style: AppFonts.montserrat13BoldPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }
}
