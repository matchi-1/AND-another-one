import 'package:flutter/material.dart';

class BeveledMenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final double width;
  final double height;
  final double fontSize;
  final Color textColor;
  final VoidCallback onTap;

  const BeveledMenuButton({
    super.key,
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.onTap,
    required this.width,
    required this.height,
    required this.textColor,
    required this.fontSize
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            // Bottom 3D shadow/base
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: shadowColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Main button face
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _lighten(color, 0.10),
                      color,
                    ],
                  ),
                  // border: Border.all(
                  //   color: Colors.white.withOpacity(0.30),
                  //   width: 2,
                  // ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      offset: Offset(5, 12),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // top gloss / bevel highlight
                    Positioned(
                      top: 0,
                      left: 2,
                      right: 2,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.40),
                              Colors.white.withOpacity(0.40),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lighter.toColor();
  }
}