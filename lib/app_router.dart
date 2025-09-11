import 'package:flutter/material.dart';
import 'package:hope/features/auth/citizen_login_screen.dart';
import 'package:hope/features/shared/splash_screen.dart';
import 'package:hope/features/auth/ngo_login_screen.dart';
import 'package:hope/features/auth/citizen_signup_screen.dart';
import 'package:hope/features/auth/ngo_signup_screen.dart';
import 'package:hope/features/citizen/citizen_dashboard_screen.dart';
import 'package:hope/features/ngo/ngo_dashboard_screen.dart'; // ✅ Add this import

class AppRouter {
  static const String splashRoute = '/';
  static const String citizenLoginRoute = '/citizen-login';
  static const String ngoLoginRoute = '/ngo-login';
  static const String citizenSignupRoute = '/citizen-signup';
  static const String ngoSignupRoute = '/ngo-signup';
  static const String citizenDashboardRoute = '/citizen-dashboard';
  static const String ngoDashboardRoute = '/ngo-dashboard'; // ✅ Added

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case citizenLoginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case ngoLoginRoute:
        return MaterialPageRoute(builder: (_) => const NGOLoginScreen());
      case citizenSignupRoute:
        return MaterialPageRoute(builder: (_) => const CitizenSignupScreen());
      case ngoSignupRoute:
        return MaterialPageRoute(builder: (_) => const NgoSignUpScreen());
      case citizenDashboardRoute:
        return MaterialPageRoute(
          builder: (_) => const CitizenDashboardScreen(),
        );
      case ngoDashboardRoute: // ✅ New route for NGO
        return MaterialPageRoute(builder: (_) => const NGODashboardScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
