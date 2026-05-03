import 'package:flutter/material.dart';
import '../../core/audio/bgm_controller.dart';
import '../../core/constants/app_assets.dart';

class MusicButton extends StatelessWidget {
  final double size;

  const MusicButton({
    super.key,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BgmController.instance.isOn,
      builder: (context, isOn, _) {
        return GestureDetector(
          onTap: () {
            BgmController.instance.toggle();
          },
          child: Image.asset(
            isOn ? AppAssets.soundOn : AppAssets.soundOff,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}