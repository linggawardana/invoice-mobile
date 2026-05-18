import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Color kBackgroundColor = Color(0xFF0B1D42);
  static const Color kCardColor = Color(0xFFF4F7FB);
  static const Color kAccentColor = Color(0xFFFAA937);
  static const Color kTextColor = Color(0xFF0F2345);
  static const TextStyle kTitleStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 26,
    height: 1.15,
  );
  static const TextStyle kDescriptionStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    height: 1.6,
  );
  static const TextStyle kHintTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 13,
  );

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showMsg("Isi semua dulu bos!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PAKAI 127.0.0.1 SESUAI GAMBAR CHROME KAMU TADI
      // Coba ganti ke localhost jika 127.0.0.1 gagal
      final url = Uri.parse("http://localhost:8000/api/register-mobile");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      print("Respon: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showMsg("BERHASIL! Data sudah masuk database.");
        Navigator.pop(context);
      } else {
        var data = jsonDecode(response.body);
        _showMsg("Gagal: ${data['message'] ?? 'Cek terminal Laravel'}");
      }
    } catch (e) {
      _showMsg("Koneksi Putus! Pastikan Server Nyala");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBackgroundColor,
        title: const Text("Register Mobile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Buat Akun Baru",
              style: kTitleStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              "Daftar sekarang untuk mengelola pelanggan dan faktur dengan cepat.",
              style: kDescriptionStyle,
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Daftar Sekarang",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text(
                "Sudah punya akun? Kembali ke login",
                textAlign: TextAlign.center,
                style: kHintTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kTextColor),
        prefixIcon: Icon(icon, color: kAccentColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
