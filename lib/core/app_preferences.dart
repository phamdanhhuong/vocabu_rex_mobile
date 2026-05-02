import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyHapticsEnabled = 'haptics_enabled';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyVoiceSpeed = 'voice_speed';

  // Singleton
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Sound Effects
  bool get isSoundEnabled => _prefs?.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) async {
    await _prefs?.setBool(_keySoundEnabled, value);
  }

  // Haptics / Vibrations
  bool get isHapticsEnabled => _prefs?.getBool(_keyHapticsEnabled) ?? true;
  Future<void> setHapticsEnabled(bool value) async {
    await _prefs?.setBool(_keyHapticsEnabled, value);
  }

  // Dark Mode
  bool get isDarkMode => _prefs?.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool(_keyDarkMode, value);
  }

  // Voice Speed (true = Normal, false = Slow)
  bool get isVoiceSpeedNormal => _prefs?.getBool(_keyVoiceSpeed) ?? true;
  Future<void> setVoiceSpeedNormal(bool value) async {
    await _prefs?.setBool(_keyVoiceSpeed, value);
  }

  // Clear all (useful on logout)
  Future<void> clearAll() async {
    await _prefs?.remove(_keySoundEnabled);
    await _prefs?.remove(_keyHapticsEnabled);
    await _prefs?.remove(_keyDarkMode);
    await _prefs?.remove(_keyVoiceSpeed);
  }
}
