import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? email;

  const PhoneVerificationScreen({super.key, this.phoneNumber, this.email});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  late TextEditingController _phoneController;

  String? _serverOtp;
  int _resendSeconds = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);

    // Start verification immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationCode();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    _startTimer();
    final authProvider = context.read<AuthProvider>();

    // Generate code via provider
    final code = await authProvider.sendVerificationCode(
      widget.phoneNumber ?? '',
    );

    if (!mounted) return;

    setState(() {
      _serverOtp = code;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your Verification Code is: $code'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'COPY',
          textColor: Colors.white,
          onPressed: () {
            _codeController.text = code;
          },
        ),
      ),
    );
  }

  void _verifyCode() {
    final input = _codeController.text;
    final authProvider = context.read<AuthProvider>();

    if (_serverOtp == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please wait for the code')));
      return;
    }

    if (authProvider.verifyCode(input, _serverOtp!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification Successful!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to game or next screen
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/game', (route) => false);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid code. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch loading state
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Verify Account',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We've sent a code to your email and phone.",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            Text(
              "Phone: ${widget.phoneNumber ?? 'Unknown'}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Email: ${widget.email ?? 'Unknown'}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Code input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter 6-digit code',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD81B60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _canResend ? _sendVerificationCode : null,
                child: Text(
                  _canResend
                      ? 'Resend Code'
                      : 'Resend Code in $_resendSeconds s',
                  style: GoogleFonts.poppins(
                    color: _canResend ? const Color(0xFF004D40) : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
