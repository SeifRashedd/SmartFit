import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/features/user/views/login_view.dart';
import 'package:smartfit/features/user/widgets/auth_header_widget.dart';
import 'package:smartfit/features/user/widgets/auth_text_form_field.dart';
import 'package:smartfit/features/user/validators/auth_validators.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreeFaceImage = false;
  bool _agreeBodyImage = false;
  bool _showAgreementError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    final validForm = _formKey.currentState?.validate() ?? false;
    final validAgreement = _agreeFaceImage && _agreeBodyImage;

    setState(() {
      _showAgreementError = !validAgreement;
    });

    if (!validForm || !validAgreement) return;
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
                const AuthHeader(
                  title: 'Create Account',
                  subtitle: 'Set up your profile and get personalized fit picks.',
                ),
                const SizedBox(height: 28),
                AuthTextFormField(
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined),
                  controller: _emailController,
                  validator: AuthValidators.email,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/egypt_round_icon_64.png', width: 30, height: 30),
                          const SizedBox(width: 8),
                          Text('+20', style: AppFonts.montserrat16MediumBlack),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AuthTextFormField(
                        hintText: 'Phone number',
                        keyboardType: TextInputType.phone,
                        prefix: const Icon(Icons.phone_outlined),
                        controller: _phoneController,
                        validator: AuthValidators.phoneEgypt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AuthTextFormField(
                  hintText: 'Password',
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline_rounded),
                  controller: _passwordController,
                  validator: AuthValidators.password,
                ),
                const SizedBox(height: 14),
                CheckboxListTile(
                  value: _agreeFaceImage,
                  onChanged: (value) => setState(() => _agreeFaceImage = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'I agree to save my face image in your database.',
                    style: AppFonts.montserrat14Regular64748B.copyWith(color: const Color(0xFF0F172A)),
                  ),
                ),
                CheckboxListTile(
                  value: _agreeBodyImage,
                  onChanged: (value) => setState(() => _agreeBodyImage = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'I agree to save my body image in your database.',
                    style: AppFonts.montserrat14Regular64748B.copyWith(color: const Color(0xFF0F172A)),
                  ),
                ),
                if (_showAgreementError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Please accept both image permissions to continue.',
                      style: AppFonts.montserrat14Regular64748B.copyWith(color: const Color(0xFFE11D48)),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your images are protected with secure storage and used only to improve your fit recommendations.',
                          style: AppFonts.montserrat14Regular64748B.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                CustomButton(
                  onPressed: _onRegisterPressed,
                  text: 'Register',
                  showIcon: true,
                  icon: const Icon(Icons.app_registration_rounded, size: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppFonts.montserrat14Regular64748B),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginView()));
                      },
                      child: Text('Login', style: AppFonts.montserrat13BoldPrimary),
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
