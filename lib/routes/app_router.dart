import 'package:flutter/material.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/main_screen.dart';
import '../presentation/screens/walk/active_walk_screen.dart';
import '../presentation/screens/walk/walk_history_screen.dart';
import '../presentation/screens/map/zone_map_screen.dart';
import '../presentation/screens/comparison/comparison_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String activeWalk = '/active-walk';
  static const String walkHistory = '/walk-history';
  static const String zoneMap = '/zone-map';
  static const String comparison = '/comparison';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        main: (_) => const MainScreen(),
        activeWalk: (_) => const ActiveWalkScreen(),
        walkHistory: (_) => const WalkHistoryScreen(),
        zoneMap: (_) => const ZoneMapScreen(),
        comparison: (_) => const ComparisonScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
