import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan import ini
import 'login_screen.dart';

// Ubah main menjadi async untuk inisialisasi locale
Future<void> main() async {
  // Pastikan widget binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data format tanggal untuk Indonesia ('id')
  // Ini akan memperbaiki error LocaleDataException yang kamu alami
  await initializeDateFormatting('id', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MIG Invoice System',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF11213D)),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    // Memberikan waktu 4.5 detik untuk menikmati animasi splash yang keren
    await Future.delayed(const Duration(milliseconds: 4500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kMIGDark = Color(0xFF11213D);
    const Color kMIGGrey = Color(0xFFADAFC6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- LOGO DIPERBESAR (220x220) ---
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_mig.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 900.ms)
                      .scale(
                        duration: 1000.ms,
                        curve: Curves.easeOutBack,
                        begin: const Offset(0.5, 0.5),
                      )
                      .then(delay: 800.ms)
                      .shimmer(duration: 1800.ms, color: Colors.black12),

                  const SizedBox(height: 40),
                  // --- JUDUL APLIKASI ---
                  Text(
                    "MIG Invoice System",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: kMIGDark,
                      letterSpacing: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutCubic),

                  const SizedBox(height: 10),

                  // --- SLOGAN ---
                  const Text(
                    "Smart. Fast. Professional.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: kMIGGrey,
                      letterSpacing: 0.8,
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 900.ms),
                ],
              ),
            ),

            // --- LOADING INDICATOR DI BAWAH ---
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      kMIGDark.withOpacity(0.6),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1.5.seconds),
            ),
          ],
        ),
      ),
    );
  }
}
