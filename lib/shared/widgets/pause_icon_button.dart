import 'package:flutter/material.dart';

class PauseIconButton extends StatelessWidget {
  const PauseIconButton({
    super.key,
    required this.onTap,
    this.size = 28,
    this.backgroundColor = const Color(0xFF0E6BFD),
    this.borderColor = Colors.white,
    this.iconColor = Colors.white,
  });

  final VoidCallback onTap;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(
            color: borderColor,
            width: 1.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Ⅱ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: iconColor,
              fontSize: size * 0.62,
              fontWeight: FontWeight.w900,
              height: 1.0,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 2,
                  offset: Offset(0, 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}