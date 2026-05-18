import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color colorMainBlue = Color(0xFF11213D);
  static const Color colorSubGrey = Color(0xFFADAFC6);
  static const Color colorAccentOrange = Color(0xFFF9C895);
  static const Color colorInputBg = Color(0xFFF5F6F8);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _failedAttempts = 0;
  bool _isLocked = false;
  int _secondsRemaining = 120;
  Timer? _timer;
  bool _isLoading = false; // Tambahan: Biar user tau lagi proses

  void _startCountdown() {
    setState(() {
      _isLocked = true;
      _secondsRemaining = 120;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
        });
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_isLocked) {
      _showLockedDialog();
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password tidak boleh kosong!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // KUNCI: Gunakan 127.0.0.1 untuk Chrome, atau 10.0.2.2 untuk Emulator
    const String apiUrl = "http://127.0.0.1:8000/api/login-mobile";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Accept": "application/json", // WAJIB untuk Laravel 11
        },
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      print("Response Login: ${response.body}");

      if (response.statusCode == 200) {
        _failedAttempts = 0;
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Berhasil! Selamat Datang.")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        _failedAttempts++;
        var errorData = jsonDecode(response.body);

        if (_failedAttempts >= 3) {
          _startCountdown();
          _showLockedDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "${errorData['message'] ?? 'Login Gagal'}! Sisa: ${3 - _failedAttempts}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Koneksi Error: Pastikan php artisan serve jalan!")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Akses Terblokir", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, color: Colors.red, size: 60),
            const SizedBox(height: 15),
            const Text("Terlalu banyak percobaan gagal. Tunggu:"),
            const SizedBox(height: 10),
            Text(
              "${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorMainBlue),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                child: Container(
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
                    .scale(curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 40),
              Text("Selamat Datang",
                  style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorMainBlue)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen())),
                child: RichText(
                  text: TextSpan(
                    text: "Belum punya akun? ",
                    style:
                        GoogleFonts.poppins(color: colorSubGrey, fontSize: 14),
                    children: const [
                      TextSpan(
                          text: "Create new account",
                          style: TextStyle(
                              color: colorAccentOrange,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildFieldInput("Username or Email", _emailController),
              const SizedBox(height: 15),
              _buildFieldInput("Password", _passwordController, isSecret: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLocked || _isLoading) ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isLocked ? Colors.grey : colorAccentOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isLocked
                              ? "Terkunci ($_secondsRemaining s)"
                              : "Sign in",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(delay: 3.seconds, color: Colors.white24),
              const SizedBox(height: 20),
              const Text("Forgot Password?",
                  style: TextStyle(
                      color: colorAccentOrange, fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR",
                          style: TextStyle(color: colorSubGrey, fontSize: 12))),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),
              _buildSocialLoginBtn("Facebook", const Color(0xFFF1F4FA),
                  Icons.facebook, const Color(0xFF39579A)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldInput(String hint, TextEditingController ctrl,
      {bool isSecret = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isSecret,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: colorSubGrey, fontSize: 14),
        filled: true,
        fillColor: colorInputBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildSocialLoginBtn(
      String title, Color bg, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(color: colorSubGrey)),
        ],
      ),
    );
  }
}
