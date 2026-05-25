import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/local_provider.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';

class BaalShravyaApp extends ConsumerWidget {
  const BaalShravyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    // watch auth state so router rebuilds when user logs in/out
    final authState = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'BaalShravya',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('kn'),
      ],
      routerConfig: GoRouter(
        redirect: (context, state) async {
          final prefs = await SharedPreferences.getInstance();
          final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

          // step 1 — onboarding check
          if (!onboardingSeen &&
              state.matchedLocation != AppRoutes.onboarding) {
            return AppRoutes.onboarding;
          }

          // step 2 — auth check
          // if user is logged in and tries to go to login/register
          // redirect to home
          final isLoggedIn = authState.user != null;
          final isAuthRoute = state.matchedLocation == AppRoutes.login ||
              state.matchedLocation == AppRoutes.register;

          if (isLoggedIn && isAuthRoute) return AppRoutes.home;

          // step 3 — protected routes
          // if user is not logged in and tries to go anywhere except
          // login, register, onboarding — redirect to login
          final isPublicRoute = isAuthRoute ||
              state.matchedLocation == AppRoutes.onboarding;

          if (!isLoggedIn && !isPublicRoute) return AppRoutes.login;

          return null;
        },
        initialLocation: AppRoutes.login,
        routes: [
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: AppRoutes.register,
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
    );
  }
}