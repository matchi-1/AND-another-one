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
  final double _targetVolume = 1.0;
  final double _duckVolume = 0.5;
  bool _isDucked = false;

  bool _pausedByLifecycle = false;
  bool _shouldResumeAfterLifecyclePause = false;

  bool get isPausedByLifecycle => _pausedByLifecycle;

  bool get _canPlayNow => isOn.value && !_pausedByLifecycle;

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
        return AppAssets.bgmLogic;
      case BgmScene.manic:
        return AppAssets.bgmManic;
    }
  }

  Future<void> playScene(BgmScene scene) async {
    debugPrint('playScene called: $scene');
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

          if (_canPlayNow) {
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

        if (_canPlayNow) {
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

        if (_currentScene != null && !_pausedByLifecycle) {
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

  Future<void> duckBgm({double? volume}) async {
  await init();

  if (!isOn.value) return;
  if (_currentScene == null) return;
  if (_isDucked) return;

  _isDucked = true;
  await _fadeTo(volume ?? _duckVolume, const Duration(milliseconds: 120));
}

Future<void> restoreBgm() async {
  await init();

  if (!isOn.value) {
    _isDucked = false;
    return;
  }
  if (_currentScene == null) {
    _isDucked = false;
    return;
  }
  if (!_isDucked) return;

  _isDucked = false;
  await _fadeTo(_targetVolume, const Duration(milliseconds: 180));
}

  Future<void> dispose() async {
    await _player.dispose();
    isOn.dispose();
    isBusy.dispose();
  }

Future<void> pauseForAppLifecycle() async {
  await init();
  if (_pausedByLifecycle) return;
  _pausedByLifecycle = true;
  _shouldResumeAfterLifecyclePause = _player.playing;

  try {
    await _player.pause();
  } catch (e) {
    debugPrint('Failed to pause BGM on app background: $e');
  }
}

Future<void> resumeFromAppLifecycle() async {
  await init();

  if (!_pausedByLifecycle) return;

  final shouldResume = _shouldResumeAfterLifecyclePause;

  _pausedByLifecycle = false;
  _shouldResumeAfterLifecyclePause = false;

  if (!shouldResume) return;
  if (!isOn.value) return;
  if (_currentScene == null) return;

  try {
    if (_currentVolume <= 0.0) {
      _currentVolume = _targetVolume;
      await _player.setVolume(_currentVolume);
    }

    unawaited(_player.play());
  } catch (e) {
    debugPrint('Failed to resume BGM on lifecycle resume: $e');
  }
}


}