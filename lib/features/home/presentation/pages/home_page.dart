import 'package:flutter/material.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_menu_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                color: AppColors.blueBg,
              ),
            ),

            // Optional decorative dots / shapes later
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.05),

                      // Temporary logo/title block
                      const Text(
                        'AND',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ANOTHER ONE!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFF2BF),
                        ),
                      ),

                      const SizedBox(height: 60),

                      PrimaryMenuButton(
                        label: 'PLAY',
                        color: AppColors.yellowButton,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.play);
                        },
                      ),
                      const SizedBox(height: 24),

                      PrimaryMenuButton(
                        label: 'LOGIC GUIDE',
                        color: AppColors.pinkButton,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.logicGuide);
                        },
                      ),
                      const SizedBox(height: 24),

                      PrimaryMenuButton(
                        label: 'SETTINGS',
                        color: AppColors.greenButton,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1;

    const gap = 32.0;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}