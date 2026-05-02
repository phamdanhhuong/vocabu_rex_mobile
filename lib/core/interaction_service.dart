import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

/// Service to handle UI sounds and haptic feedback
class InteractionService {
  static final InteractionService _instance = InteractionService._internal();
  factory InteractionService() => _instance;

  InteractionService._internal();

  // Create multiple players to allow overlapping sounds (e.g., tap + success)
  final AudioPlayer _primaryPlayer = AudioPlayer();
  final AudioPlayer _secondaryPlayer = AudioPlayer();
  bool _usePrimary = true;

  final AppPreferences _prefs = AppPreferences();

  // Helper to play sound with alternating players
  Future<void> _playSound(String assetPath) async {
    if (!_prefs.isSoundEnabled) return;
    try {
      final player = _usePrimary ? _primaryPlayer : _secondaryPlayer;
      _usePrimary = !_usePrimary;

      // Stop current playback on this player and play new sound
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (e) {
      print('InteractionService error playing sound: $e');
    }
  }

  /// Rung nhẹ khi bấm nút bình thường (không phát âm thanh)
  static Future<void> playTap() async {
    final instance = InteractionService();
    if (instance._prefs.isHapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Phát âm thanh khi trả lời đúng
  static Future<void> playSuccess() async {
    final instance = InteractionService();
    if (instance._prefs.isHapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    await instance._playSound('sounds/duolingo-correct.mp3');
  }

  /// Phát âm thanh khi trả lời sai
  static Future<void> playError() async {
    final instance = InteractionService();
    if (instance._prefs.isHapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    await instance._playSound('sounds/duolingo-wrong.mp3');
  }

  /// Phát âm thanh khi nhận thưởng / lên cấp
  static Future<void> playReward() async {
    final instance = InteractionService();
    if (instance._prefs.isHapticsEnabled) {
      HapticFeedback.vibrate();
    }
    await instance._playSound('sounds/duolingo-completed-lesson.mp3');
  }
}
