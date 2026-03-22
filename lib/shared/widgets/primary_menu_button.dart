import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

class PrimaryMenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PrimaryMenuButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(label, style: AppTextStyles.menuButton),
          ),
        ),
      ),
    );
  }
}