import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/navigation/app_routes.dart';
import 'gameplay_tutorial_overlay.dart';
import 'gameplay_tutorial_service.dart';
import 'tutorial_targets.dart';

class TutorialStepSpec {
  final String? targetId;
  final String text;
  final String andyAsset;

  final TutorialOverlayPlacement andyPlacement;
  final TutorialOverlayPlacement dialoguePlacement;

  final double andyWidthFactor;
  final double dialogueWidthFactor;

  const TutorialStepSpec({
    required this.targetId,
    required this.text,
    required this.andyAsset,
    this.andyPlacement = TutorialPositions.bottomLeft,
    this.dialoguePlacement = TutorialPositions.topCenter,
    this.andyWidthFactor = 0.60,
    this.dialogueWidthFactor = 0.90,
  });
}
class TutorialPageSpec {
  final String routeName;
  final List<TutorialStepSpec> steps;

  const TutorialPageSpec({
    required this.routeName,
    required this.steps,
  });
}

class AppTutorialController {
  AppTutorialController._();

  static final AppTutorialController instance = AppTutorialController._();

  final GameplayTutorialService _service = GameplayTutorialService();

  static const String _flagName = 'hasSeenMainPlaceholderTutorial';

  bool _active = false;
  int _pageIndex = 0;
  OverlayEntry? _entry;

  String _playerName = 'Player';

  bool get isActive => _active;

  void setPlayerName(String playerName) {
    final cleaned = playerName.trim();

    if (cleaned.isEmpty) {
      _playerName = 'Player';
      return;
    }

    _playerName = cleaned;
  }

  List<TutorialPageSpec> get _flow => [
        TutorialPageSpec(
          routeName: AppRoutes.home,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'Hey, $_playerName! I’m Andy. Welcome to AND Another One, where logic gates become a game!',
              andyAsset: AppAssets.tutorialAndy1,

                // Andy appears at bottom-left.
              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                //offset: Offset(0, 20),
              ),

              //andyWidthFactor: 0.58,
              //dialogueWidthFactor: 0.90,
            ),


            const TutorialStepSpec(
              targetId: null,
              text:
                  'This is the home page. From here, you can play, study logic gates, check rankings, or restart this tutorial anytime.',
              andyAsset: AppAssets.tutorialAndy1,
              
              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                //offset: Offset(0, 20),
              ),
            ),


            const TutorialStepSpec(
              targetId: 'homePlay',
              text:
                  'Tap PLAY when you’re ready to jump into the logic challenges.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -175),
              ),

            ),


            const TutorialStepSpec(
              targetId: 'homeLogicGuide',
              text:
                  'Need a refresher? The LOGIC GUIDE explains the operators and Boolean Algebra rules before you start solving.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -175),
              ),
            ),


            const TutorialStepSpec(
              targetId: 'homeLeaderboards',
              text:
                  'The LEADERBOARDS show who’s dominating the circuit board.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topLeft,
                offset: Offset(-20, 100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomCenter,
                offset: Offset(0, -300),
              ),
              
            ),


            const TutorialStepSpec(
              targetId: 'homeRestart',
              text:
                  'Forgot something? You can replay this tutorial here anytime.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topLeft,
                offset: Offset(-20, 100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomCenter,
                offset: Offset(0, -300),
              ),

            ),
          ],
        ),
        const TutorialPageSpec(
          routeName: AppRoutes.selectMode,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'After pressing play, you can choose your game mode. Each mode tests logic in a different way.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, 70),
              ),

            ),
            TutorialStepSpec(
              targetId: 'modeGatekeeping',
              text:
                  'In Gatekeeping, you fill in the missing logic operator that completes the expression.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -90),
              ),


            ),
            TutorialStepSpec(
              targetId: 'modeOneOrNone',
              text:
                  'In One or None, you decide whether the whole circuit outputs a 1 or a 0.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topLeft,
                offset: Offset(-20, 100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomCenter,
                offset: Offset(0, -300),
              ),

            ),
            TutorialStepSpec(
              targetId: 'modeBack',
              text:
                  'Use BACK whenever you want to return to the previous screen.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topLeft,
                offset: Offset(-20, 100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomCenter,
                offset: Offset(0, -300),
              ),

            ),
          ],
        ),
        const TutorialPageSpec(
          routeName: AppRoutes.gatekeepingSelect,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'This is the Gatekeeping difficulty screen. You\'ll find a similar difficulty screen for One or None. Pick the level that matches your confidence.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, 50),
              ),


            ),
            TutorialStepSpec(
              targetId: 'gateHowToPlay',
              text:
                  'The \'HOW TO PLAY?\' button gives a more detailed explanation of this mode.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, 50),
              ),
            ),


            TutorialStepSpec(
              targetId: 'gateBasic',
              text:
                  'BASIC is the best place to start. It uses simpler gates and friendlier patterns.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -100),
              ),

            ),
            TutorialStepSpec(
              targetId: 'gateLogic',
              text:
                  'LOGIC adds more challenge, so expect trickier operator combinations.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -100),
              ),

              andyWidthFactor: 0.56
            ),


            TutorialStepSpec(
              targetId: 'gateManic',
              text:
                  'MANIC is fast, chaotic, and definitely not for sleepy brains.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topLeft,
                offset: Offset(-20, 100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomCenter,
                offset: Offset(0, -300),
              ),
            ),


            TutorialStepSpec(
              targetId: 'gateBack',
              text:
                  'Not ready yet? This BACK button returns you to mode select.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topLeft,
                offset: Offset(-20, 100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomCenter,
                offset: Offset(0, -300),
              ),
            ),
          ],
        ),


        const TutorialPageSpec(
          routeName: AppRoutes.gatekeepingTutorialPreview,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'Before your first real round, let me show you how the game screen for Gatekeeping works.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                //offset: Offset(0, 20),
              ),

            ),


            TutorialStepSpec(
              targetId: 'previewDiagram',
              text:
                  'This area shows the circuit diagram. Read the gates and follow how the signals connect.',
              andyAsset: AppAssets.tutorialAndy1,
            ),


            TutorialStepSpec(
              targetId: 'previewExpression',
              text:
                  'This expression area is the main question. There will be blank boxes you need to fill with operators.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -150),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                //offset: Offset(0, 20),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewExpression',
              text:
                  'Filling all the boxes with the correct operators will give you another diagram and expression.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -150),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                //offset: Offset(0, 20),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewExpression',
              text:
                  'Getting even just one of them incorrect will not give you a new diagram and expression.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -150),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                //offset: Offset(0, 20),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewExpression',
              text:
                  'There is NO LIMIT to the number of expressions you can solve.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -150),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                //offset: Offset(0, 20),
              ),
            ),


            TutorialStepSpec(
              targetId: 'previewButtons',
              text:
                  'Choose the operator buttons that will correctly complete the expression.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 150),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                offset: Offset(0, 300),
              ),
            ),


            TutorialStepSpec(
              targetId: 'previewTimer',
              text:
                  'Here’s the timer in seconds. Correct answers will add 2 seconds to it, but wrong answers will deduct 1 second to it.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),

            TutorialStepSpec(
              targetId: 'previewTimer',
              text:
                  'When the timer reaches 0, the game will end and you\'ll see a preview of your score and other stats.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),


            TutorialStepSpec(
              targetId: 'previewMultiplierStreak',
              text:
                  'This part shows you your current streak and multiplier.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),

            TutorialStepSpec(
              targetId: 'previewMultiplierStreak',
              text:
                  'Every two correct answers will increase your multiplier tier, while every incorrect answer will decrease it.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),


            TutorialStepSpec(
              targetId: 'previewScore',
              text:
                  'Here is your current score. Getting a correct answer will increase it by the base score of the difficulty, multiplied by your current multiplier.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewScore',
              text:
                  'Getting an incorrect answer will decrease it by just the base score of the difficulty.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),


            TutorialStepSpec(
              targetId: 'previewPass',
              text:
                  'Stuck? Press this PASS button to skip a question, but you only get a limited number of passes per game.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),


            TutorialStepSpec(
              targetId: 'previewPassesLeft',
              text:
                  'Passes will not affect your current streak, multiplier, score, or timer. Use them wisely!',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewBackspace',
              text:
                  'If you pressed the wrong operator button, you can press this backspace button to clear the single rightmost filled box in the expression.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),


            TutorialStepSpec(
              targetId: 'previewBack',
              text:
                  'If you want to pause the game to retry the level or exit back to the home page, just press this button to do so.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewBack',
              text:
                  'This will stop the timer until you press resume.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),


            TutorialStepSpec(
              targetId: 'previewHelp',
              text:
                  'If you want to see the operator names and some other helpful info, you can press this help button to show an overview.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),

            TutorialStepSpec(
              targetId: 'previewHelp',
              text:
                  'But doing so will NOT pause the timer.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),


            TutorialStepSpec(
              targetId: null,
              text:
                  'That’s it for Gatekeeping! Read the circuit, fill in the blanks with operators, and get as many correct answers as you can within the time limit.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),


            ),
          ],
        ),

        

        const TutorialPageSpec(
          routeName: AppRoutes.oneOrNoneTutorialPreview,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'Now let’s check the One or None game screen. This mode asks you to decide whether the circuit output is 1 or 0.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                //offset: Offset(0, 20),
              ),
            ),


            TutorialStepSpec(
              targetId: 'onePreviewLives',
              text:
                  'Instead of a timer, One or None uses lives. Wrong answers cost lives, and there is no way to recover them. Think carefully before you answer!',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),


            TutorialStepSpec(
              targetId: 'onePreviewMultiplierStreak',
              text:
                  'Streaks and Multipliers work the same way as in Gatekeeping.',
              andyAsset: AppAssets.tutorialAndy2,
              
              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

              dialogueWidthFactor: 0.78,
            ),


            TutorialStepSpec(
              targetId: 'onePreviewScore',
              text:
                  'So do scores and base difficulty score values.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),


            TutorialStepSpec(
              targetId: 'onePreviewDiagram',
              text:
                  'Just like in Gatekeeping, you will be given a circuit diagram.',
              andyAsset: AppAssets.tutorialAndy1,
            ),


            TutorialStepSpec(
              targetId: 'onePreviewValues',
              text:
                  'But unlike in Gatekeeping, you are given the current input values. Use them to evaluate the circuit, whether they\'ll result in a 1 or a 0.',
              andyAsset: AppAssets.tutorialAndy3,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                offset: Offset(0, 40),
              ),
            ),

            TutorialStepSpec(
              targetId: 'onePreviewValues',
              text:
                  'Keep in mind that an incorrect answer WILL RANDOMIZE these input values every time, so you will have to reevaluate them.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                offset: Offset(0, 40),
              ),
            ),

            TutorialStepSpec(
              targetId: 'onePreviewValues',
              text:
                  'Just like in Gatekeeping, a correct answer will give you a new diagram and input values, and there is NO LIMIT to how many you can solve.',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, -100),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                offset: Offset(0, 40),
              ),
            ),


            TutorialStepSpec(
              targetId: 'onePreviewButtons',
              text:
                  'Choose 1 if the circuit output is true, or 0 if the circuit output is false.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 150),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                offset: Offset(0, 300),
              ),

            ),


            TutorialStepSpec(
              targetId: 'onePreviewPass',
              text:
                  'Passes work the same way as in Gatekeeping, not affecting your streak, multiplier, score, lives, and skipping the diagram. They are also limited per game.',
              andyAsset: AppAssets.tutorialAndy1,

              
              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),

            TutorialStepSpec(
              targetId: 'onePreviewBack',
              text:
                  'The same pause button is present in this game mode.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),

            TutorialStepSpec(
              targetId: 'onePreviewHelp',
              text:
                  'The same help button is also here.',
              andyAsset: AppAssets.tutorialAndy2,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),
            ),


            TutorialStepSpec(
              targetId: null,
              text:
                  'And that’s the full tour! You’re now ready to play both modes. Good luck!',
              andyAsset: AppAssets.tutorialAndy1,

              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.centerLeft,
                offset: Offset(0, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.center,
                offset: Offset(0, -200),
              ),

            ),
          ],
        ),
      ];

  Future<void> maybeStart(BuildContext context) async {
    if (_active) return;

    final seen = await _service.hasSeen(_flagName);
    if (seen) return;
    if (!context.mounted) return;

    await start(context);
  }

  Future<void> start(BuildContext context) async {
    _removeOverlay();
    _active = true;
    _pageIndex = 0;

    final firstRoute = _flow.first.routeName;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == firstRoute) {
      onPageReady(context, firstRoute);
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      firstRoute,
      (route) => false,
    );
  }

  void onPageReady(BuildContext context, String currentRouteName) {
    if (!_active) return;
    if (_entry != null) return;
    if (_pageIndex >= _flow.length) return;

    final spec = _flow[_pageIndex];
    if (spec.routeName != currentRouteName) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || !_active || _entry != null) return;
      _showPageOverlay(context, spec);
    });
  }

  void _showPageOverlay(BuildContext context, TutorialPageSpec spec) {
    final steps = spec.steps
      .map(
        (step) => GameplayTutorialStep(
          targetKey: tutorialTargetById(step.targetId),
          text: step.text,
          andyAsset: step.andyAsset,
          andyPlacement: step.andyPlacement,
          dialoguePlacement: step.dialoguePlacement,
          andyWidthFactor: step.andyWidthFactor,
          dialogueWidthFactor: step.dialogueWidthFactor,
        ),
      )
      .toList();

    _removeOverlay();

    _entry = OverlayEntry(
      builder: (_) => GameplayTutorialOverlay(
        steps: steps,

        // Normal tutorial progression.
        onFinish: () async {
          _removeOverlay();

          if (_pageIndex >= _flow.length - 1) {
            await _finishTutorial(context);
            return;
          }

          _pageIndex++;
          final nextRoute = _flow[_pageIndex].routeName;

          if (!context.mounted) return;

          Navigator.of(context).pushReplacementNamed(nextRoute);
        },

        // X button: skip the whole tutorial immediately.
        onSkip: () async {
          await stop(context, markSeen: true);
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  Future<void> _finishTutorial(BuildContext context) async {
    _removeOverlay();
    _active = false;
    _pageIndex = 0;

    await _service.markSeen(_flagName);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.home) return;

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> stop(BuildContext context, {bool markSeen = true}) async {
    _removeOverlay();
    _active = false;
    _pageIndex = 0;

    if (markSeen) {
      await _service.markSeen(_flagName);
    }

    if (!context.mounted) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Important:
    // If we are already on Home, do NOT push another Home page.
    // Pushing another Home causes duplicated GlobalKeys.
    if (currentRoute == AppRoutes.home) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }
}

class TutorialPageReady extends StatefulWidget {
  const TutorialPageReady({
    super.key,
    required this.routeName,
    required this.child,
  });

  final String routeName;
  final Widget child;

  @override
  State<TutorialPageReady> createState() => _TutorialPageReadyState();
}

class _TutorialPageReadyState extends State<TutorialPageReady> {
  bool _notified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notified) return;
    _notified = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppTutorialController.instance.onPageReady(context, widget.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}