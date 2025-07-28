import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('User Responsibilities'),
                    _buildListItem(
                      'You agree to provide accurate, complete, and up-to-date information when creating your account.',
                    ),
                    _buildListItem(
                      'You are responsible for maintaining the confidentiality of your login credentials.',
                    ),
                    _buildListItem(
                      'You agree to report any unauthorized use or suspicious activity on your account immediately.',
                    ),
                    _buildListItem(
                      'You will use Gaming platform solely for lawful purposes related to skill-based gaming.',
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Acceptable Use'),
                    _buildListItem(
                      'You will not engage in any illegal, fraudulent, or harmful activities while using Gaming platform.',
                    ),
                    _buildListItem(
                      'You agree not to upload, share, or distribute content that is unlawful, offensive, or inappropriate.',
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Gameplay & Rewards'),
                    _buildListItem(
                      'All competitions and games are based on skill. No gambling or betting activities are allowed.',
                    ),
                    _buildListItem(
                      'Virtual rewards, points, and ranks have no cash value and cannot be exchanged for real currency.',
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Intellectual Property'),
                    _buildListItem(
                      'All content, trademarks, logos, and intellectual property on Gaming platform are owned or licensed by us.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) =>
                      setState(() => _isChecked = value!),
                  activeColor: const Color(0xFFD81B60),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'By creating an account, you agree to the terms of use and privacy policy.',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // *** MODIFIED THIS SECTION ***
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Disagree',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isChecked
                        ? () {
                            // Navigate to the phone verification screen after agreeing
                            Navigator.of(context).pushNamed('/phone-verify');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD81B60),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'I Agree',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black54)),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
