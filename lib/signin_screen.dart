import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'repositories/user_repository.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Initialize GoogleSignIn with clientId.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '987383237018-0h1qmbn4528k7cditspks0j19jvr75jf.apps.googleusercontent.com', // <-- Add your client ID here
  );

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

      // *** FIXED: Re-added 'await' as authentication is an async operation ***
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Could not retrieve Google ID token.');
      }

      final response = await http.post(
        Uri.parse('flutter run'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome ${googleUser.displayName}!')),
        );
        Navigator.of(context).pushReplacementNamed('/game');
      } else {
        throw Exception(
          'Failed to authenticate with server: ${response.statusCode} ${response.body}',
        );
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
    if (_validateEmail(_emailController.text)) {
      try {
        final user = await _userRepository.validateUser(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
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
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (c, e, s) => const Icon(Icons.error, size: 80),
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
                _buildTextField(hint: 'Password', obscureText: true),
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
        onPressed: () => Navigator.of(context).pushNamed('/game'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD81B60),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
          shadowColor: Colors.pink.withAlpha(102),
        ),
        child: Text(
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
