import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../constants/app_assets.dart';
import 'bgm_controller.dart';

class SfxController {
  SfxController._();
  static final SfxController instance = SfxController._();

  final AudioPlayer _passPlayer = AudioPlayer();
  final AudioPlayer _operatorPlayerA = AudioPlayer();
  final AudioPlayer _operatorPlayerB = AudioPlayer();
  final AudioPlayer _backspacePlayer = AudioPlayer();
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _gameOverPlayer = AudioPlayer();
  final AudioPlayer _countdownPlayer = AudioPlayer();
  final AudioPlayer _menuPressPlayer = AudioPlayer();
  final AudioPlayer _menuBackPlayer = AudioPlayer();
  final AudioPlayer _playSelectPlayer = AudioPlayer();

  bool _initialized = false;
  bool _useOperatorA = true;

List<AudioPlayer> get _allPlayers => [
  _passPlayer,
  _operatorPlayerA,
  _operatorPlayerB,
  _backspacePlayer,
  _correctPlayer,
  _wrongPlayer,
  _gameOverPlayer,
  _countdownPlayer,
  _menuPressPlayer,
  _menuBackPlayer,
  _playSelectPlayer,
  
];
Future<void> stopAllForLifecycle() async {
  if (!_initialized) return;

  await Future.wait(
    _allPlayers.map((player) async {
      try {
        await player.pause();
        await player.seek(Duration.zero);
      } catch (e) {
        debugPrint('Failed to stop SFX on app background: $e');
      }
    }),
  );
}
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _countdownPlayer.setAsset(AppAssets.sfxCountdown);
    await _countdownPlayer.setVolume(1.0);
    await _countdownPlayer.setLoopMode(LoopMode.off);

    await Future.wait([
      _passPlayer.setAsset(AppAssets.sfxPass),
      _operatorPlayerA.setAsset(AppAssets.sfxOperatorTap),
      _operatorPlayerB.setAsset(AppAssets.sfxOperatorTap2),
      _backspacePlayer.setAsset(AppAssets.sfxBackspace),
      _correctPlayer.setAsset(AppAssets.sfxCorrect),
      _wrongPlayer.setAsset(AppAssets.sfxWrong),
      _gameOverPlayer.setAsset(AppAssets.sfxGameOver),
      _menuPressPlayer.setAsset(AppAssets.sfxMenuPress),
      _menuBackPlayer.setAsset(AppAssets.sfxMenuBack),
      _playSelectPlayer.setAsset(AppAssets.sfxPlaySelect),
    ]);

    await Future.wait([
      _passPlayer.setLoopMode(LoopMode.off),
      _operatorPlayerA.setLoopMode(LoopMode.off),
      _operatorPlayerB.setLoopMode(LoopMode.off),
      _backspacePlayer.setLoopMode(LoopMode.off),
      _correctPlayer.setLoopMode(LoopMode.off),
      _wrongPlayer.setLoopMode(LoopMode.off),
      _gameOverPlayer.setLoopMode(LoopMode.off),
      _menuPressPlayer.setLoopMode(LoopMode.off),
      _menuBackPlayer.setLoopMode(LoopMode.off),
      _playSelectPlayer.setLoopMode(LoopMode.off),
    ]);

    await Future.wait([
      _passPlayer.setVolume(1.0),
      _operatorPlayerA.setVolume(1.0),
      _operatorPlayerB.setVolume(1.0),
      _backspacePlayer.setVolume(1.0),
      _correctPlayer.setVolume(1.0),
      _wrongPlayer.setVolume(1.0),
      _gameOverPlayer.setVolume(1.0),
      _menuPressPlayer.setVolume(1.0),
      _menuBackPlayer.setVolume(1.0),
      _playSelectPlayer.setVolume(1.0),
    ]);
  }

  Future<void> _play(AudioPlayer player) async {
  await init();

  if (!BgmController.instance.isOn.value) return;

  try {
    await player.pause();
    await player.seek(Duration.zero);
    unawaited(player.play());
  } catch (e, st) {
    // Temporarily keep this while debugging release/device playback.
    // Later you can reduce it if it gets noisy.
    debugPrint('SFX playback failed: $e');
    debugPrintStack(stackTrace: st);
  }
}

  Future<void> playPass() async {
    await _play(_passPlayer);
  }

  Future<void> playOperatorTap() async {
    // Alternate between 2 players so rapid taps feel more responsive.
    final player = _useOperatorA ? _operatorPlayerA : _operatorPlayerB;
    _useOperatorA = !_useOperatorA;
    await _play(player);
  }

  Future<void> playBackspace() async {
    await _play(_backspacePlayer);
  }

  Future<void> playCorrect() async {
    await _play(_correctPlayer);
  }

  Future<void> playWrong() async {
    await _play(_wrongPlayer);
  }

  Future<void> playGameOver() async {
    await _play(_gameOverPlayer);
  }

  Future<void> playCountdown() async {
  await init();

  if (!BgmController.instance.isOn.value) return;

  try {
    unawaited(BgmController.instance.duckBgm());

    await _countdownPlayer.pause();
    await _countdownPlayer.seek(Duration.zero);
    unawaited(_countdownPlayer.play());

    await _countdownPlayer.playerStateStream.firstWhere(
      (state) => state.processingState == ProcessingState.completed,
    );

    await BgmController.instance.restoreBgm();
  } catch (e, st) {
    debugPrint('Countdown playback failed: $e');
    debugPrintStack(stackTrace: st);
  }
}

  Future<void> playMenuPress() async {
    await _play(_menuPressPlayer);
  }

  Future<void> playMenuBack() async {
    await _play(_menuBackPlayer);
  }

  Future<void> playPlaySelect() async {
    await _play(_playSelectPlayer);
  }

  Future<void> dispose() async {
  await Future.wait([
    _passPlayer.dispose(),
    _operatorPlayerA.dispose(),
    _operatorPlayerB.dispose(),
    _backspacePlayer.dispose(),
    _correctPlayer.dispose(),
    _wrongPlayer.dispose(),
    _gameOverPlayer.dispose(),
    _countdownPlayer.dispose(),
    _menuPressPlayer.dispose(),
    _menuBackPlayer.dispose(),
    _playSelectPlayer.dispose(),
  ]);
}
}