import 'package:flutter/material.dart';
import 'package:namer_app/auth_manager.dart';
import 'package:namer_app/theme/app_theme.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthManager(),
      builder: (context, child) {
        final auth = AuthManager();
        final username = auth.username;
        final appTheme = AppTheme.getTheme(auth.currentTheme, gender: auth.gender);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appTheme.isBrutalist) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: appTheme.primary,
                    child: Text(
                      'SELAMAT_DATANG',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: appTheme.fontFamily,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  Text(
                    'Selamat Datang,',
                    style: TextStyle(
                      color: appTheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: appTheme.fontFamily,
                      fontSize: 14,
                    ),
                  ),
                ],
                Text(
                  appTheme.isBrutalist ? username.toUpperCase() : username,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: appTheme.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: appTheme.onSurface,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const ProfileScreen()),
                // );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: appTheme.onSurface, width: 2),
                  shape: appTheme.isCute ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: appTheme.isCute 
                      ? null 
                      : (appTheme.isBrutalist ? BorderRadius.zero : BorderRadius.circular(8)),
                ),
                child: Icon(Icons.home, color: appTheme.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }
}
