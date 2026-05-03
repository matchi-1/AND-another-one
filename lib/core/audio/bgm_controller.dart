import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../constants/app_assets.dart';

enum BgmScene {
  home,
  basic,
  logic,
  manic,
}

class BgmController {
  BgmController._();
  static final BgmController instance = BgmController._();

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> isOn = ValueNotifier<bool>(true);

  bool _initialized = false;
  bool _busy = false;

  BgmScene? _currentScene;
  double _currentVolume = 0.0;
  final double _targetVolume = 0.80;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.0);
    _currentVolume = 0.0;
  }

  String _assetFor(BgmScene scene) {
    switch (scene) {
      case BgmScene.home:
        return AppAssets.bgmHome;
      case BgmScene.basic:
        return AppAssets.bgmBasic;
      case BgmScene.logic:
        return AppAssets.bgmBasic;
      case BgmScene.manic:
        return AppAssets.bgmManic;
    }
  }

  Future<void> playScene(BgmScene scene) async {
    await init();

    if (_busy) return;
    if (_currentScene == scene && _player.playing) return;

    _busy = true;
    try {
      await _fadeTo(0.0, const Duration(milliseconds: 250));
      await _player.pause();

      _currentScene = scene;
      await _player.setAsset(_assetFor(scene));

      if (isOn.value) {
        await _player.play();
        await _fadeTo(_targetVolume, const Duration(milliseconds: 350));
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> toggle() async {
    await init();

    if (isOn.value) {
      isOn.value = false;
      await _fadeTo(0.0, const Duration(milliseconds: 250));
      await _player.pause();
    } else {
      isOn.value = true;
      if (_currentScene != null) {
        await _player.play();
        await _fadeTo(_targetVolume, const Duration(milliseconds: 350));
      }
    }
  }

  Future<void> _fadeTo(double target, Duration duration) async {
    const steps = 10;
    final start = _currentVolume;
    final delta = (target - start) / steps;
    final stepMs = duration.inMilliseconds ~/ steps;

    for (int i = 1; i <= steps; i++) {
      final next = start + (delta * i);
      _currentVolume = next.clamp(0.0, 1.0);
      await _player.setVolume(_currentVolume);
      await Future.delayed(Duration(milliseconds: stepMs));
    }
  }

  Future<void> stop() async {
    await _fadeTo(0.0, const Duration(milliseconds: 200));
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
    isOn.dispose();
  }
}