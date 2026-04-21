import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart'; // TAMBAHKAN INI

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const Color colorMainBlue = Color(0xFF11213D);
  static const Color colorSubGrey = Color(0xFFADAFC6);
  static const Color colorAccentOrange = Color(0xFFF9C895);
  static const Color colorInputBg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: colorMainBlue,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                "Hello! Buat Akun.",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorMainBlue,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: "Sudah punya akun? ",
                    style: GoogleFonts.poppins(
                      color: colorSubGrey,
                      fontSize: 14,
                    ),
                    children: const [
                      TextSpan(
                        text: "Masuk",
                        style: TextStyle(
                          color: colorAccentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildFieldInput("Your name"),
              const SizedBox(height: 15),
              _buildFieldInput("Username or Email"),
              const SizedBox(height: 15),
              _buildFieldInput("Password", isSecret: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // SIMULASI DAFTAR & MASUK KE DASHBOARD
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 40),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR",
                      style: TextStyle(color: colorSubGrey, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),
              _buildSocialLoginBtn(
                "Connect with Facebook",
                const Color(0xFFF1F4FA),
                iconWidget: const Icon(
                  Icons.facebook,
                  color: Color(0xFF39579A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 15),
              _buildSocialLoginBtn(
                "Connect with Google",
                colorInputBg,
                iconWidget: Image.asset(
                  'assets/images/logo_google.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldInput(String hintText, {bool isSecret = false}) {
    return TextField(
      obscureText: isSecret,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: colorSubGrey, fontSize: 14),
        filled: true,
        fillColor: colorInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildSocialLoginBtn(
    String title,
    Color background, {
    required Widget iconWidget,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          iconWidget,
          Expanded(
            child: Center(
              child: Text(
                title,
                style: GoogleFonts.poppins(color: colorSubGrey, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}
