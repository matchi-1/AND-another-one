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
    return AnimatedBuilder(
      animation: Listenable.merge([
        BgmController.instance.isOn,
        BgmController.instance.isBusy,
      ]),
      builder: (context, _) {
        final isOn = BgmController.instance.isOn.value;
        final isBusy = BgmController.instance.isBusy.value;

        return IgnorePointer(
          ignoring: isBusy,
          child: Opacity(
            opacity: isBusy ? 0.65 : 1.0,
            child: GestureDetector(
              onTap: () async {
                await BgmController.instance.toggle();
              },
              child: Image.asset(
                isOn ? AppAssets.soundOn : AppAssets.soundOff,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}