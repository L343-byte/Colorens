import 'package:flutter/material.dart';
import 'package:colorlens/screens/splash/splash_screen.dart';
import 'package:colorlens/screens/onboarding/onboarding_screen.dart';
import 'package:colorlens/screens/auth/login_screen.dart';
import 'package:colorlens/screens/auth/register_screen.dart';
import 'package:colorlens/screens/auth/forgot_password_screen.dart';
import 'package:colorlens/screens/home/dashboard_screen.dart';
import 'package:colorlens/screens/test/test_catalog_screen.dart';
import 'package:colorlens/screens/test/ishihara/ishihara_test_screen.dart';
import 'package:colorlens/screens/test/ishihara/ishihara_result_screen.dart';
import 'package:colorlens/screens/test/hrr/hrr_test_screen.dart';
import 'package:colorlens/screens/test/hrr/hrr_result_screen.dart';
import 'package:colorlens/screens/camera/camera_scanner_screen.dart';
import 'package:colorlens/screens/profile/profile_screen.dart';
import 'package:colorlens/screens/profile/user_settings_screen.dart';

/// Defines the application routes.
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String testCatalog = '/test-catalog';
  static const String ishiharaTest = '/test/ishihara';
  static const String ishiharaResult = '/test/ishihara-result';
  static const String hrrTest = '/test/hrr';
  static const String hrrResult = '/test/hrr-result';
  static const String camera = '/camera';
  static const String profile = '/profile';
  static const String userSettings = '/user-settings';

  /// Generates routes based on the provided settings.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case testCatalog:
        return MaterialPageRoute(builder: (_) => const TestCatalogScreen());
      case ishiharaTest:
        return MaterialPageRoute(builder: (_) => const IshiharaTestScreen());
      case ishiharaResult:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const IshiharaResultScreen(),
        );
      case hrrTest:
        return MaterialPageRoute(builder: (_) => const HRRTestScreen());
      case hrrResult:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HRRResultScreen(),
        );
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraScannerScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case userSettings:
        return MaterialPageRoute(builder: (_) => const UserSettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
