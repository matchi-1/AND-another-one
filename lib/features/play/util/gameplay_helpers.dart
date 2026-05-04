import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../leaderboards/util/leaderboard_service.dart';

mixin GameplayHelpers<T extends StatefulWidget> on State<T> {
  final LeaderboardService leaderboardService = LeaderboardService();

  Timer? gameplayTimer;

  bool scoreSubmitted = false;
  

  int currentQuestionIndex = 0;
  int timeLeft = 0;
  int score = 0;
  int passesLeft = 0;

  bool roundLocked = false;
  bool gameFinished = false;

  Color flashColor = Colors.transparent;
  double flashOpacity = 0.0;

  String? scoreDeltaText;
  Color scoreDeltaColor = Colors.white;
  double scoreDeltaOpacity = 0.0;
  double scoreDeltaYOffset = 0.0;
  double scoreDeltaXOffset = 0.0;

  String? centerPopupText;
  Color centerPopupColor = Colors.white;
  double centerPopupOpacity = 0.0;
  double centerPopupScale = 0.9;

  int get startingRoundTime;
  int get startingPasses;
  String get modeId;
  String get difficultyId;
  int get questionCount;

  void loadCurrentQuestion();
  void goToNextQuestion();
  void onRetryCurrentQuestion();
  void resetWholeGame();

  void initializeSharedRun() {
    scoreSubmitted = false;
    gameplayTimer?.cancel();

    currentQuestionIndex = 0;
    score = 0;
    passesLeft = startingPasses;
    gameFinished = false;
    roundLocked = false;
    timeLeft = startingRoundTime;

    loadCurrentQuestion();
    startGameplayTimer();
    setState(() {});
  }

  void startGameplayTimer() {
    gameplayTimer?.cancel();

    gameplayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || roundLocked || gameFinished) return;

      if (timeLeft <= 1) {
        setState(() {
          timeLeft = 0;
        });
        handleTimeout();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  Future<void> handlePass() async {
    if (roundLocked || gameFinished) return;
    if (passesLeft <= 0) return;

    HapticFeedback.mediumImpact();

    setState(() {
      passesLeft--;
    });

    showCenterPopup('PASS', const Color(0xFFFFB347));

    await finishRound(
      scoreDelta: -10,
      timeDelta: 0,
      advanceQuestion: true,
    );
  }

  Future<void> handleTimeout() async {
    if (gameFinished) return;
    await _performTimeout();
  }

  Future<void> _performTimeout() async {
    if (gameFinished) return;

    HapticFeedback.heavyImpact();

    setState(() {
      gameFinished = true;
      roundLocked = true;
      timeLeft = 0;
    });

    gameplayTimer?.cancel();
    await submitFinalScoreOnce();

    if (!mounted) return;
    showEndDialog();
  }

  Future<void> finishRound({
    required int scoreDelta,
    required int timeDelta,
    required bool advanceQuestion,
  }) async {
    setState(() {
      roundLocked = true;
      score = (score + scoreDelta).clamp(0, 999999);
      timeLeft = (timeLeft + timeDelta).clamp(0, 999999);
    });

    await Future.delayed(const Duration(milliseconds: 850));

    if (!mounted || gameFinished) return;

    // if (advanceQuestion && currentQuestionIndex >= questionCount - 1) {
    //   await submitFinalScoreOnce();
    //   if (!mounted) return;
    //   showEndDialog();
    //   return;
    // }

    if (timeLeft <= 0) {
      await _performTimeout();
      return;
    }

    if (advanceQuestion) {
      setState(() {
        roundLocked = false;
        goToNextQuestion();
      });
    } else {
        setState(() {
          onRetryCurrentQuestion();
          roundLocked = false;
        });
      }
  }

  Future<void> playFlash({bool isCorrect = false}) async {
    if (!mounted) return;
    setState(() {
      flashColor = isCorrect ? Colors.green : Colors.red;
      flashOpacity = isCorrect ? 0.65 : 0.75;
    });

    await Future.delayed(
      Duration(milliseconds: isCorrect ? 300 : 135),
    );
    if (!mounted) return;

    setState(() {
      flashOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 135));
  }

  Future<void> playWrongDamageFlash() async {
    await playFlash();
    await Future.delayed(const Duration(milliseconds: 40));
    await playFlash();
  }

  Future<void> showScoreDelta(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      scoreDeltaText = text;
      scoreDeltaColor = color;
      scoreDeltaOpacity = 1.0;
      scoreDeltaYOffset = 0.0;
      scoreDeltaXOffset = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      scoreDeltaYOffset = -15.0;
      scoreDeltaXOffset = -10.0;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      scoreDeltaOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      scoreDeltaText = null;
      scoreDeltaYOffset = 0.0;
      scoreDeltaXOffset = 0.0;
    });
  }

  Future<void> showCenterPopup(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      centerPopupText = text;
      centerPopupColor = color;
      centerPopupOpacity = 1.0;
      centerPopupScale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      centerPopupOpacity = 0.0;
      centerPopupScale = 1.08;
    });

    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() {
      centerPopupText = null;
      centerPopupScale = 0.9;
    });
  }

  Future<void> submitFinalScoreOnce() async {
    if (scoreSubmitted) return;
    scoreSubmitted = true;

    await leaderboardService.submitScore(
      modeId: modeId,
      difficultyId: difficultyId,
      score: score,
    );
  }

  void showEndDialog() {
    gameplayTimer?.cancel();
    gameFinished = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ROUND COMPLETE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Final Score: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetWholeGame();
              },
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'EXIT',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    gameplayTimer?.cancel();
    super.dispose();
  }
}