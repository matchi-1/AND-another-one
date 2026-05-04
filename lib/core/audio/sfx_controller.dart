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

  bool _initialized = false;
  bool _useOperatorA = true;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await Future.wait([
      _passPlayer.setAsset(AppAssets.sfxPass),
      _operatorPlayerA.setAsset(AppAssets.sfxOperatorTap),
      _operatorPlayerB.setAsset(AppAssets.sfxOperatorTap2),
      _backspacePlayer.setAsset(AppAssets.sfxBackspace),
      _correctPlayer.setAsset(AppAssets.sfxCorrect),
      _wrongPlayer.setAsset(AppAssets.sfxWrong),
      _gameOverPlayer.setAsset(AppAssets.sfxGameOver),
    ]);

    await Future.wait([
      _passPlayer.setLoopMode(LoopMode.off),
      _operatorPlayerA.setLoopMode(LoopMode.off),
      _operatorPlayerB.setLoopMode(LoopMode.off),
      _backspacePlayer.setLoopMode(LoopMode.off),
      _correctPlayer.setLoopMode(LoopMode.off),
      _wrongPlayer.setLoopMode(LoopMode.off),
      _gameOverPlayer.setLoopMode(LoopMode.off),
    ]);

    await Future.wait([
      _passPlayer.setVolume(1.0),
      _operatorPlayerA.setVolume(1.0),
      _operatorPlayerB.setVolume(1.0),
      _backspacePlayer.setVolume(1.0),
      _correctPlayer.setVolume(1.0),
      _wrongPlayer.setVolume(1.0),
      _gameOverPlayer.setVolume(1.0),
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