import 'package:flutter/material.dart';

class BeveledMenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final double width;
  final double height;
  final double fontSize;
  final Color textColor;
  final VoidCallback onTap;

  const BeveledMenuButton({
    super.key,
    required this.label,
    required this.color,
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
                  //   color: Colors.white.withValues(alpha: 0.30),
                  //   width: 2,
                  // ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      offset: Offset(5, 8),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // top gloss / bevel highlight
                    Positioned(
                      top: 1,
                      left: 2,
                      right: 3,
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular (15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.20),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // left highlight
                    Positioned(
                      top: 5,
                      left: 0,
                      child: Container(
                        height: height,
                        width: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular (15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // right shadow
                    Positioned(
                      top: 5,
                      right: 0,
                      child: Container(
                        height: height,
                        width: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular (2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.20),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // bottom shadow
                    Positioned(
                      bottom: 0,
                      left: 2,
                      right: 8,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular (2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.20),
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
