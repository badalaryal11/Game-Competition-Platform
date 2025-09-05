import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email');
      return false;
    }
    setState(() => _emailError = null);
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return false;
    }
    if (password.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      return false;
    }
    setState(() => _passwordError = null);
    return true;
  }

  bool _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      return false;
    }
    setState(() => _confirmPasswordError = null);
    return true;
  }

  void _handleSignUp() {
    final isEmailValid = _validateEmail(_emailController.text);
    final isPasswordValid = _validatePassword(_passwordController.text);
    final isConfirmPasswordValid = _validateConfirmPassword(
      _confirmPasswordController.text,
    );

    if (isEmailValid && isPasswordValid && isConfirmPasswordValid) {
      // Proceed with sign up
      Navigator.of(context).pushNamed('/privacy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Create An Account',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Play games. Sharpen your skills. Earn Money. Connect with other gamers.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                _buildInputField(
                  hintText: 'Email Address',
                  controller: _emailController,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  errorText: _passwordError,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  errorText: _confirmPasswordError,
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD81B60),
                      padding: const EdgeInsets.symmetric(vertical: 18),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        // borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.poppins(color: Colors.grey[400]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFFD81B60),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    bool obscureText = false,
    TextEditingController? controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFD81B60)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
      ),
    );
  }
}
