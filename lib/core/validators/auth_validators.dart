class AuthValidators {
  static String? required(String? value, {required String message}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return message;
    return null;
  }
  static String? email(String? value) {
    final requiredErr = required(
      value,
      message: 'Email is required',
    );
    if (requiredErr != null) return requiredErr;

    final email = (value ?? '').trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }
  static String? password(String? value) {
    final requiredErr = required(
      value,
      message: 'Password is required',
    );
    if (requiredErr != null) return requiredErr;

    final password = (value ?? '').trim();
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
  static String? phoneEgypt(String? value) {
    final requiredErr = required(
      value,
      message: 'Phone number is required',
    );
    if (requiredErr != null) return requiredErr;

    final phone = (value ?? '').trim();
    final phoneRegex = RegExp(r'^\d{10,11}$');
    if (!phoneRegex.hasMatch(phone)) return 'Enter a valid Egyptian number';
    return null;
  }
}

