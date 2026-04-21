import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart'; // TAMBAHKAN INI

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color colorMainBlue = Color(0xFF11213D);
  static const Color colorSubGrey = Color(0xFFADAFC6);
  static const Color colorAccentOrange = Color(0xFFF9C895);
  static const Color colorInputBg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Center(
                child:
                    Container(
                          height: 140,
                          width: 140,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo_mig.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          delay: 200.ms,
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),
              ),
              const SizedBox(height: 40),
              Text(
                "Selamat Datang",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorMainBlue,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    text: "Belum punya akun? ",
                    style: GoogleFonts.poppins(
                      color: colorSubGrey,
                      fontSize: 14,
                    ),
                    children: const [
                      TextSpan(
                        text: "Create new account",
                        style: TextStyle(
                          color: colorAccentOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildFieldInput("Username or Email"),
              const SizedBox(height: 15),
              _buildFieldInput("Password", isSecret: true),
              const SizedBox(height: 30),
              SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // NAVIGASI KE DASHBOARD
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
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    delay: 3.seconds,
                    duration: 1500.ms,
                    color: Colors.white24,
                  ),
              const SizedBox(height: 20),
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: colorAccentOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                const Color(0xFF39579A),
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
                colorSubGrey,
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
    Color textColor,
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
