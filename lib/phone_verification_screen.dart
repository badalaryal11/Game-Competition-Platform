import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
    // Mock sending code on init
    _sendVerificationCode();
  }

  void _sendVerificationCode() {
    // Mock logic: In a real app, call API to send SMS and Email here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification code sent to ${widget.phoneNumber} and ${widget.email}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _verifyCode() {
    // Mock verification
    if (_codeController.text == '123456') {
      Navigator.of(context).pushReplacementNamed('/game');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid code. Try 123456'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              "Email: ${widget.email ?? 'Unknown'}",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
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
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black,
                ),
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
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD81B60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
                child: Text(
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
                onPressed: _sendVerificationCode,
                child: Text(
                  'Resend Code',
                   style: GoogleFonts.poppins(
                    color: const Color(0xFF004D40),
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
