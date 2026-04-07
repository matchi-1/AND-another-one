import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';

class GatekeepingGamePage extends StatelessWidget {
  const GatekeepingGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        useGrid: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // const SizedBox(height: 20),

              // row with Back and Sound buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset(AppAssets.backBtn, width: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const MusicButton(size: 32),
                  ],
                ),
              ),

              //const SizedBox(height: 20),

              // diagram container for logic guide
              Image.asset(
                AppAssets.diagramContainerGreen,
                width: size.width,
              ),

              const SizedBox(height: 20),

              // beige rectangle container under diagram -- for explanation content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.beigeBg,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'choices and pass and backspace here',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
