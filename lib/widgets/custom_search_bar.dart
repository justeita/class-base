import 'package:flutter/material.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.getTheme(AuthManager().currentTheme, gender: AuthManager().gender);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: appTheme.surface,
        border: appTheme.isBrutalist 
            ? Border.all(color: appTheme.onSurface.withValues(alpha: 0.2)) 
            : appTheme.isManly
                ? Border.all(color: appTheme.primary.withValues(alpha: 0.2))
                : null,
        borderRadius: appTheme.isBrutalist 
            ? BorderRadius.zero 
            : appTheme.isCute
                ? BorderRadius.circular(32)
                : appTheme.isManly
                    ? BorderRadius.circular(8)
                    : BorderRadius.circular(12),
        boxShadow: appTheme.isBrutalist ? null : [
          BoxShadow(
            color: appTheme.isCute
                ? appTheme.primary.withValues(alpha: 0.15)
                : appTheme.isManly
                    ? appTheme.primary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: appTheme.isManly ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: appTheme.isBrutalist ? '> CARI_DATABASE...' : 'Cari...',
          hintStyle: TextStyle(
            color: appTheme.onSurface.withValues(alpha: 0.4),
            fontFamily: appTheme.fontFamily,
          ),
          icon: Icon(
            appTheme.isBrutalist ? Icons.terminal : Icons.search, 
            color: appTheme.primary.withValues(alpha: 0.7)
          ),
        ),
        style: TextStyle(
          color: appTheme.onSurface,
          fontFamily: appTheme.fontFamily,
        ),
      ),
    );
  }
}
