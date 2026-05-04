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
  final ValueNotifier<bool> isBusy = ValueNotifier<bool>(false);

  bool _initialized = false;

  BgmScene? _currentScene;
  BgmScene? _requestedScene;
  Future<void>? _transitionFuture;

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
        return AppAssets.bgmBasic2;
      case BgmScene.logic:
        return AppAssets.bgmLogic2;
      case BgmScene.manic:
        return AppAssets.bgmManic;
    }
  }

  Future<void> playScene(BgmScene scene) async {
    await init();

    _requestedScene = scene;

    if (_transitionFuture != null) {
      return _transitionFuture!;
    }

    _transitionFuture = _processSceneQueue();
    try {
      await _transitionFuture;
    } finally {
      _transitionFuture = null;
    }
  }

  Future<void> _processSceneQueue() async {
    isBusy.value = true;
    try {
      while (_requestedScene != null) {
        final scene = _requestedScene!;
        _requestedScene = null;

        final asset = _assetFor(scene);
        final firstLoad = _currentScene == null;

        // If already on this exact scene and already playing correctly, skip.
        if (_currentScene == scene &&
            ((isOn.value && _player.playing) || (!isOn.value && !_player.playing))) {
          continue;
        }

        _currentScene = scene;

        if (firstLoad) {
          await _player.setAsset(asset);
          await _player.setVolume(0.0);
          _currentVolume = 0.0;

          if (isOn.value) {
            unawaited(_player.play());
            await _fadeTo(_targetVolume, const Duration(milliseconds: 120));
          }
          continue;
        }

        // Full stop is more reliable than pause when swapping assets quickly.
        await _fadeTo(0.0, const Duration(milliseconds: 80));
        await _player.stop();

        await _player.setAsset(asset);
        await _player.setVolume(0.0);
        _currentVolume = 0.0;

        if (isOn.value) {
          unawaited(_player.play());
          await _fadeTo(_targetVolume, const Duration(milliseconds: 120));
        }
      }
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> toggle() async {
    await init();

    if (isBusy.value) return;

    isBusy.value = true;
    try {
      if (isOn.value) {
        isOn.value = false;
        await _fadeTo(0.0, const Duration(milliseconds: 80));
        await _player.pause();
      } else {
        isOn.value = true;

        if (_currentScene != null) {
          await _player.setVolume(0.0);
          _currentVolume = 0.0;

          unawaited(_player.play());
          await _fadeTo(_targetVolume, const Duration(milliseconds: 120));
        }
      }
    } finally {
      isBusy.value = false;
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
    await init();
    if (isBusy.value) return;

    isBusy.value = true;
    try {
      await _fadeTo(0.0, const Duration(milliseconds: 80));
      await _player.stop();
      _currentVolume = 0.0;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    isOn.dispose();
    isBusy.dispose();
  }
}