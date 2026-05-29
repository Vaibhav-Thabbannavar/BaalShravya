import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baalshravya_app/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/providers/local_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider);

    return Drawer(
      child: Column(
        children: [

          // drawer header with user info
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              user?.name ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              user?.phone ?? '',
              style: const TextStyle(fontSize: 13),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Text(
                // first letter of name as avatar
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            otherAccountsPictures: [
              // role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.role.toUpperCase() ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // language switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.language, size: 18,
                    color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  l10n.language,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // toggle between English and Kannada
                GestureDetector(
                  onTap: () {
                    final isEnglish = locale.languageCode == 'en';
                    ref.read(localeProvider.notifier).setLocale(
                          Locale(isEnglish ? 'kn' : 'en'),
                        );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _LangTab(
                          label: 'EN',
                          isActive: locale.languageCode == 'en',
                        ),
                        _LangTab(
                          label: 'ಕನ್ನಡ',
                          isActive: locale.languageCode == 'kn',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // awareness
         ListTile(
            leading: const Icon(
              Icons.campaign_outlined,
              color: AppColors.primary,
            ),
            title: Text(l10n.awareness),
            onTap: () {
              Navigator.pop(context); // close drawer first
              context.push(AppRoutes.awareness);
            },
          ),

          const Spacer(),

          const Divider(),

          // logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LangTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _LangTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}