import 'package:flutter/material.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';

class FeaturedCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;
  final String index;

  const FeaturedCard({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final appTheme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme.surface,
        gradient: appTheme.isManly
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appTheme.surface,
                  appTheme.surface.withValues(alpha: 0.9),
                ],
              )
            : null,
        border: appTheme.isBrutalist
            ? Border(
                left: BorderSide(color: color, width: 4),
                bottom: BorderSide(color: color, width: 4),
                top: BorderSide(color: appTheme.onSurface.withValues(alpha: 0.1), width: 1),
                right: BorderSide(color: appTheme.onSurface.withValues(alpha: 0.1), width: 1),
              )
            : appTheme.isManly
                ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
                : null,
        borderRadius: appTheme.isBrutalist 
            ? null 
            : appTheme.isCute 
                ? BorderRadius.circular(32) // Extra rounded for cute theme
                : appTheme.isManly
                    ? BorderRadius.circular(8) // Sharper for manly theme
                    : BorderRadius.circular(16),
        boxShadow: appTheme.isBrutalist
            ? null
            : [
                BoxShadow(
                  color: appTheme.isCute 
                      ? color.withValues(alpha: 0.25) // Colored shadow for cute theme
                      : color.withValues(alpha: appTheme.isManly ? 0.15 : 0.2),
                  blurRadius: appTheme.isManly ? 20 : 15,
                  offset: appTheme.isManly ? const Offset(0, 10) : const Offset(0, 8),
                  spreadRadius: appTheme.isManly ? -5 : 0,
                ),
              ],
      ),
      child: Stack(
        children: [
          if (appTheme.isCute)
            Positioned(
              top: -10,
              right: -10,
              child: Icon(Icons.bubble_chart, color: color.withValues(alpha: 0.1), size: 60),
            ),
          if (appTheme.isManly)
            Positioned(
              bottom: -20,
              right: -20,
              child: Transform.rotate(
                angle: 0.5,
                child: Icon(Icons.hexagon_outlined, color: color.withValues(alpha: 0.1), size: 80),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Text(
                    index,
                    style: TextStyle(
                      color: appTheme.onSurface.withValues(alpha: 0.1),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: appTheme.fontFamily,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appTheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: appTheme.fontFamily,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appTheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontFamily: appTheme.fontFamily,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const FeatureCard({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthManager();
    final appTheme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);
    
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: appTheme.isCute 
            ? BorderRadius.circular(32) 
            : appTheme.isManly 
                ? BorderRadius.circular(8) 
                : BorderRadius.circular(24),
        border: appTheme.isManly ? Border.all(color: color.withValues(alpha: 0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: appTheme.isManly 
                ? color.withValues(alpha: 0.1) 
                : appTheme.isCute 
                    ? color.withValues(alpha: 0.15) 
                    : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: appTheme.onSurface,
              fontFamily: appTheme.fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              color: appTheme.onSurface.withValues(alpha: 0.6),
              fontFamily: appTheme.fontFamily,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
