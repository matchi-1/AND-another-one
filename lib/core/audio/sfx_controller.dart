import 'dart:async';
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

    // Reuse the same global mute toggle for now.
    if (!BgmController.instance.isOn.value) return;

    try {
      await player.stop();
      await player.seek(Duration.zero);
      unawaited(player.play());
    } catch (_) {
      // ignore occasional playback hiccups
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

      await _countdownPlayer.stop();
      await _countdownPlayer.seek(Duration.zero);
      unawaited(_countdownPlayer.play());

      _countdownPlayer.playerStateStream
          .firstWhere((state) => state.processingState == ProcessingState.completed)
          .then((_) => BgmController.instance.restoreBgm());
    } catch (_) {}
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
    ]);
  }
}