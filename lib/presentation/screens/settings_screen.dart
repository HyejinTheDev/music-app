import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/settings/settings_bloc.dart';
import '../../logic/settings/settings_event.dart';
import '../../logic/settings/settings_state.dart';
import '../../l10n/app_localizations.dart';

/// Màn hình Cài đặt — chế độ sáng/tối + ngôn ngữ
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
        final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subtitleColor = isDark ? Colors.white54 : Colors.black54;
        final dividerColor = isDark ? Colors.white10 : Colors.black12;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              loc.translate('settings_title'),
              style: TextStyle(color: textColor),
            ),
            iconTheme: IconThemeData(color: textColor),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== SECTION: GIAO DIỆN =====
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  loc.translate('appearance'),
                  style: TextStyle(
                    color: Colors.tealAccent[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  activeColor: Colors.tealAccent,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.tealAccent.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? Colors.tealAccent : Colors.amber,
                    ),
                  ),
                  title: Text(
                    loc.translate('dark_mode'),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isDark
                        ? loc.translate('dark_mode_sub')
                        : loc.translate('light_mode_sub'),
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                  value: isDark,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(ToggleThemeEvent());
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ===== SECTION: NGÔN NGỮ =====
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  loc.translate('language'),
                  style: TextStyle(
                    color: Colors.tealAccent[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildLanguageTile(
                      context: context,
                      flag: '🇻🇳',
                      title: loc.translate('vietnamese'),
                      languageCode: 'vi',
                      isSelected: settings.locale.languageCode == 'vi',
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                    ),
                    Divider(color: dividerColor, height: 1, indent: 60),
                    _buildLanguageTile(
                      context: context,
                      flag: '🇺🇸',
                      title: loc.translate('english'),
                      languageCode: 'en',
                      isSelected: settings.locale.languageCode == 'en',
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Thông tin phiên bản
              Center(
                child: Text(
                  'Music App Pro v1.0.0',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String flag,
    required String title,
    required String languageCode,
    required bool isSelected,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.tealAccent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(flag, style: const TextStyle(fontSize: 24)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.tealAccent)
          : Icon(Icons.circle_outlined, color: subtitleColor),
      onTap: () {
        context.read<SettingsBloc>().add(SetLocaleEvent(languageCode));
      },
    );
  }
}
