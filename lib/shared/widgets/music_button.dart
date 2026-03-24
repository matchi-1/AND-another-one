import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';

class MusicButton extends StatefulWidget {
  final double size;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const MusicButton({
    super.key,
    this.size = 40.0,
    this.initialValue = true,
    this.onChanged,
  });

  @override
  State<MusicButton> createState() => _MusicButtonState();
}

class _MusicButtonState extends State<MusicButton> {
  late bool _isToggled;

  @override
  void initState() {
    super.initState();
    _isToggled = widget.initialValue;
  }

  void _handleTap() {
    setState(() {
      _isToggled = !_isToggled;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_isToggled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Image.asset(
        _isToggled ? AppAssets.soundOn : AppAssets.soundOff,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }
}
