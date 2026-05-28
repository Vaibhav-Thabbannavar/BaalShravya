import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/local_provider.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/infant/presentation/add_infant_screen.dart';
import 'features/infant/presentation/infant_list_screen.dart';
import 'features/infant/presentation/infant_profile_screen.dart';
import 'features/screening/presentation/start_session_screen.dart';
import 'features/screening/presentation/session_dashboard_screen.dart';
import 'features/questionnaire/presentation/questionnaire_screen.dart';
import 'features/boa/presentation/boa_screen.dart';
import 'features/screening/presentation/report_screen.dart';

class BaalShravyaApp extends ConsumerWidget {
  const BaalShravyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
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

          if (!onboardingSeen &&
              state.matchedLocation != AppRoutes.onboarding) {
            return AppRoutes.onboarding;
          }

          final isLoggedIn = authState.user != null;
          final isAuthRoute =
              state.matchedLocation == AppRoutes.login ||
              state.matchedLocation == AppRoutes.register;

          if (isLoggedIn && isAuthRoute) return AppRoutes.home;

          final isPublicRoute =
              isAuthRoute ||
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
          GoRoute(
            path: AppRoutes.addInfant,
            builder: (context, state) => const AddInfantScreen(),
          ),
          GoRoute(
            path: '/infants',
            builder: (context, state) => const InfantListScreen(),
          ),
          // :infantId is a path parameter
          // state.pathParameters['infantId'] reads it
          GoRoute(
            path: '/infant/:infantId',
            builder: (context, state) => InfantProfileScreen(
              infantId: state.pathParameters['infantId']!,
            ),
          ),

          GoRoute(
            path: '/start-session/:infantId',
            builder: (context, state) =>
                StartSessionScreen(infantId: state.pathParameters['infantId']!),
          ),
          GoRoute(
            path: '/session/:sessionId',
            builder: (context, state) => SessionDashboardScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),

          GoRoute(
            path: '/questionnaire/:sessionId',
            builder: (context, state) => QuestionnaireScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),

          GoRoute(
            path: '/boa/:sessionId',
            builder: (context, state) =>
                BoaScreen(sessionId: state.pathParameters['sessionId']!),
          ),

          GoRoute(
            path: '/report/:sessionId',
            builder: (context, state) => ReportScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),

        ],
      ),
    );
  }
}