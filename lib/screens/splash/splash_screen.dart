import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/config/routes.dart';

/// Splash screen dengan animasi halus (Scale in logo, glowing ring pulse, dan slide-up teks)
/// Mengikuti standar UX agar pembukaan aplikasi terasa responsif, elegan, dan profesional.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _ringScaleAnimation;
  late Animation<double> _ringOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Controller untuk animasi muncul (Entrance: 1000 ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Easing elastis lembut untuk logo (scale-in)
    _logoScaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Animasi teks meluncur halus dari bawah (Slide-up + Fade)
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.95, curve: Curves.easeOutCubic),
          ),
        );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.85, curve: Curves.easeIn),
      ),
    );

    // 2. Controller untuk pendaran cincin emas (Glow Ring Pulse: 1500 ms)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _ringScaleAnimation = Tween<double>(begin: 0.95, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    _ringOpacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    // Jalankan animasi
    _entranceController.forward();
    _pulseController.repeat();

    // Waktu tunggu ideal (1.8 detik) untuk memuat data sesi sebelum navigasi
    Future.delayed(const Duration(milliseconds: 1900), _checkNavigation);
  }

  Future<void> _checkNavigation() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;

      // Cek Firebase Auth secara aman (tidak crash di web atau saat offline)
      User? currentUser;
      try {
        currentUser = FirebaseAuth.instance.currentUser;
      } catch (e) {
        debugPrint('Firebase Auth belum diinisialisasi / mode offline web: $e');
      }

      if (!mounted) return;

      final String targetRoute = !hasSeenOnboarding
          ? AppRoutes.onboarding
          : (currentUser != null ? AppRoutes.home : AppRoutes.login);

      Navigator.pushReplacementNamed(context, targetRoute);
    } catch (e) {
      debugPrint('Error navigasi splash: $e');
      if (mounted) {
        // Fallback aman: langsung arahkan ke onboarding/login
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Latar belakang gradient Navy modern
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003D6A), // Navy gelap
              AppTheme.primaryNavy, // Navy standar Colorlens
              Color(0xFF006BB8), // Aksen biru atas
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: [
            // Konten Tengah (Logo, Cincin Cahaya, dan Judul)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo + Glow Ring Stack
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cincin Pendaran Emas (Pulse Ring)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _ringOpacityAnimation.value,
                              child: Transform.scale(
                                scale: _ringScaleAnimation.value,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.accentGold.withValues(
                                        alpha: 0.8,
                                      ),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Logo Utama dengan Scale-In & Fade
                        AnimatedBuilder(
                          animation: _entranceController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacityAnimation.value,
                              child: Transform.scale(
                                scale: _logoScaleAnimation.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: AppTheme.accentGold,
                                      width: 3.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentGold.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Teks Animasi Meluncur (Slide-Up & Fade)
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _textSlideAnimation,
                        child: Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: const Column(
                            children: [
                              Text(
                                'Colorlens',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Visual Test & Deteksi Warna Pelajar',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Indikator status bawah (Loading Sesi)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentGold.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Memuat sistem...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
