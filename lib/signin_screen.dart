import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'repositories/user_repository.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Initialize GoogleSignIn.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final _userRepository = UserRepository();

  bool _rememberMe = false;
  bool _isLoading = false;

  // Add controllers at the top of the class
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Add error states
  String? _emailError;
  String? _passwordError;

  // Add dispose method
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Add email validation method
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
    setState(() => _passwordError = null);
    return true;
  }

  Future<void> _handleSignInAndBackendAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-in was cancelled.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Check if user exists in local database
      final authProvider = context.read<AuthProvider>();
      final email = googleUser.email;
      final exists = await authProvider.checkUserExists(email);

      if (mounted) {
        if (exists) {
          // User exists, log them in directly
          await authProvider.googleSignInSuccess(email);
          Navigator.of(context).pushReplacementNamed('/game');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back ${googleUser.displayName}!')),
          );
        } else {
          // User does not exist, redirect to SignUp with pre-filled data
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => SignUpScreen(
                    initialEmail: email,
                    initialFullName: googleUser.displayName,
                  ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please complete your registration to continue.',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    final emailValid = _validateEmail(_emailController.text);
    final passwordValid = _validatePassword(_passwordController.text);

    if (emailValid && passwordValid) {
      setState(() => _isLoading = true);

      try {
        await context.read<AuthProvider>().signIn(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          // Use /game to match the Google Sign-In behavior
          Navigator.of(context).pushReplacementNamed('/game');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
              ), // Clean up error message
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.08),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/icon.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Welcome!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to keep leveling up your skills.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                _buildTextField(
                  hint: 'Email Address',
                  controller: _emailController,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  hint: 'Password',
                  obscureText: true,
                  controller: _passwordController,
                  errorText: _passwordError,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v!),
                      activeColor: const Color(0xFFD81B60),
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildSignInButton(),
                SizedBox(height: screenHeight * 0.02),
                _buildRegisterNow(),
                SizedBox(height: screenHeight * 0.04),
                _buildSocialsDivider(),
                SizedBox(height: screenHeight * 0.04),
                _buildSocialButton(
                  onPressed: _isLoading ? null : _handleSignInAndBackendAuth,
                  label: 'Sign In with Google',
                  assetPath: 'assets/images/google_logo.png',
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  onPressed: () {},
                  label: 'Sign In with Apple',
                  assetPath: 'assets/images/apple_logo.png',
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    bool obscureText = false,
    TextEditingController? controller,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
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
      onChanged: (value) {
        if (hint == 'Email Address') {
          _validateEmail(value);
        }
      },
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD81B60),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
          shadowColor: Colors.pink.withAlpha(102),
        ),
        child: _isLoading
            ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.white),
            )
            : Text(
              'Sign In',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      ),
    );
  }

  Widget _buildRegisterNow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Do not have account? ',
          style: GoogleFonts.poppins(color: Colors.grey[700]),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/signup'),
          child: const Text(
            'Register now',
            style: TextStyle(
              color: Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialsDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Login with Socials',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required String label,
    required String assetPath,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: _isLoading && label == 'Sign In with Google'
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                assetPath,
                height: 24,
                width: 24,
                errorBuilder: (c, e, s) => const Icon(Icons.error, size: 24),
              ),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
