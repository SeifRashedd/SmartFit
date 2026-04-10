import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/core/styles/app_colors.dart';
import 'package:smartfit/core/styles/app_fonts.dart';
import 'package:smartfit/core/widgets/custom_button.dart';
import 'package:smartfit/core/widgets/styled_dialog.dart';
import 'package:smartfit/features/auth/cubit/auth_cubit.dart';
import 'package:smartfit/features/auth/views/login_view.dart';
import 'package:smartfit/features/auth/widgets/auth_header_widget.dart';
import 'package:smartfit/features/auth/widgets/auth_text_form_field.dart';
import 'package:smartfit/features/face_dect/views/detect_face_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _agreeFaceImage = false;
  bool _agreeBodyImage = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    context.read<AuthCubit>().signUp(email: _emailController.text.trim(), password: _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.appPadding,
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
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is SignUpSuccess) {
                      showStyledDialog(
                        context,
                        title: 'Account Created',
                        message: 'Your account has been created successfully!',
                        isSuccess: true,
                        onClose: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const DetectFaceView()),
                            (route) => false,
                          );
                        },
                      );
                    } else if (state is SignUpFailure) {
                      showStyledDialog(
                        context,
                        title: 'Registration Failed',
                        message: state.errorMessage,
                        isSuccess: false,
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is SignUpLoading;

                    return CustomButton(
                      onPressed: isLoading ? () {} : _onRegisterPressed,
                      text: isLoading ? 'Loading...' : 'Register',
                      showIcon: true,
                      icon: const Icon(Icons.app_registration_rounded, size: 18),
                    );
                  },
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
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }
}
