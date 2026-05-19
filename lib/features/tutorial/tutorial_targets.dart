import 'package:flutter/material.dart';

class TutorialTargets {
  // Home
  static final homePlay = GlobalKey();
  static final homeLogicGuide = GlobalKey();
  static final homeLeaderboards = GlobalKey();
  static final homeRestart = GlobalKey();
  static final homeExit = GlobalKey();
  static final homeLogout = GlobalKey();

  // Mode Select
  static final modeGatekeeping = GlobalKey();
  static final modeOneOrNone = GlobalKey();
  static final modeBack = GlobalKey();

  // Gatekeeping Select
  static final gateHowToPlay = GlobalKey();
  static final gateBasic = GlobalKey();
  static final gateLogic = GlobalKey();
  static final gateManic = GlobalKey();
  static final gateBack = GlobalKey();

  // Tutorial Preview page
  static final previewDiagram = GlobalKey();
  static final previewExpression = GlobalKey();
  static final previewButtons = GlobalKey();
  static final previewTimer = GlobalKey();
  static final previewPass = GlobalKey();
  static final previewBack = GlobalKey();
  static final previewMultiplierStreak = GlobalKey();
  static final previewPassesLeft = GlobalKey();
  static final previewBackspace = GlobalKey();
  static final previewScore = GlobalKey();
  static final previewHelp = GlobalKey();

  // Tutorial Preview page - One or None
  static final onePreviewLives = GlobalKey();
  static final onePreviewMultiplierStreak = GlobalKey();
  static final onePreviewScore = GlobalKey();
  static final onePreviewDiagram = GlobalKey();
  static final onePreviewValues = GlobalKey();
  static final onePreviewPass = GlobalKey();
  static final onePreviewButtons = GlobalKey();
  static final onePreviewBack = GlobalKey();
  static final onePreviewHelp = GlobalKey();

}

GlobalKey? tutorialTargetById(String? id) {
  switch (id) {
    case 'homePlay':
      return TutorialTargets.homePlay;
    case 'homeLogicGuide':
      return TutorialTargets.homeLogicGuide;
    case 'homeLeaderboards':
      return TutorialTargets.homeLeaderboards;
    case 'homeRestart':
      return TutorialTargets.homeRestart;
    case 'homeExit':
      return TutorialTargets.homeExit;
    case 'homeLogout':
      return TutorialTargets.homeLogout;

    case 'modeGatekeeping':
      return TutorialTargets.modeGatekeeping;
    case 'modeOneOrNone':
      return TutorialTargets.modeOneOrNone;
    case 'modeBack':
      return TutorialTargets.modeBack;

    case 'gateHowToPlay':
      return TutorialTargets.gateHowToPlay;
    case 'gateBasic':
      return TutorialTargets.gateBasic;
    case 'gateLogic':
      return TutorialTargets.gateLogic;
    case 'gateManic':
      return TutorialTargets.gateManic;
    case 'gateBack':
      return TutorialTargets.gateBack;

    case 'previewDiagram':
      return TutorialTargets.previewDiagram;
    case 'previewExpression':
      return TutorialTargets.previewExpression;
    case 'previewButtons':
      return TutorialTargets.previewButtons;
    case 'previewTimer':
      return TutorialTargets.previewTimer;
    case 'previewPass':
      return TutorialTargets.previewPass;
    case 'previewBack':
      return TutorialTargets.previewBack;
    case 'previewMultiplierStreak':
      return TutorialTargets.previewMultiplierStreak;
    case 'previewPassesLeft':
      return TutorialTargets.previewPassesLeft;
    case 'previewBackspace':
      return TutorialTargets.previewBackspace;
    case 'previewScore':
      return TutorialTargets.previewScore;
    case 'previewHelp':
      return TutorialTargets.previewHelp;

    case 'onePreviewLives':
      return TutorialTargets.onePreviewLives;
    case 'onePreviewMultiplierStreak':
      return TutorialTargets.onePreviewMultiplierStreak;
    case 'onePreviewScore':
      return TutorialTargets.onePreviewScore;
    case 'onePreviewDiagram':
      return TutorialTargets.onePreviewDiagram;
    case 'onePreviewValues':
      return TutorialTargets.onePreviewValues;
    case 'onePreviewPass':
      return TutorialTargets.onePreviewPass;
    case 'onePreviewButtons':
      return TutorialTargets.onePreviewButtons;
    case 'onePreviewBack':
      return TutorialTargets.onePreviewBack;
    case 'onePreviewHelp':
      return TutorialTargets.onePreviewHelp;


      }
  return null;
}