import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  static List<dynamic>? _cachedVoices;

  /// Sets the TTS voice dynamically based on the requested gender.
  /// Falls back to default English voices if a specific match is not found.
  static Future<void> setDynamicVoice(
    FlutterTts tts,
    String gender, {
    String locale = 'en-gb',
  }) async {
    try {
      if (_cachedVoices == null || _cachedVoices!.isEmpty) {
        _cachedVoices = await tts.getVoices;
        if (_cachedVoices == null || _cachedVoices!.isEmpty) {
          // Give TTS engine time to bind on some Android devices (like Xiaomi)
          await Future.delayed(const Duration(milliseconds: 500));
          _cachedVoices = await tts.getVoices;
        }
      }

      final voices = _cachedVoices;

      if (voices == null || voices.isEmpty) {
        print('⚠️ No voices available or TTS not bound. Falling back to setLanguage.');
        await tts.setLanguage(locale);
        return;
      }

      final targetGender = gender.toLowerCase();
      final targetLocale = locale.toLowerCase();

      // 1. Exact match for locale and gender
      dynamic selectedVoice = voices.firstWhere((voice) {
        final name = voice['name']?.toString().toLowerCase() ?? '';
        final voiceLocale = voice['locale']?.toString().toLowerCase() ?? '';
        return voiceLocale.contains(targetLocale) && name.contains(targetGender);
      }, orElse: () => null);

      // 2. Fallback: Any voice matching locale
      selectedVoice ??= voices.firstWhere(
        (voice) =>
            voice['locale']?.toString().toLowerCase().contains(targetLocale) ?? false,
        orElse: () => null,
      );

      // 3. Fallback: Any English voice
      selectedVoice ??= voices.firstWhere(
        (voice) =>
            voice['locale']?.toString().toLowerCase().startsWith('en') ?? false,
        orElse: () => null,
      );

      if (selectedVoice != null) {
        final voiceMap = {
          'name': selectedVoice['name']?.toString() ?? '',
          'locale': selectedVoice['locale']?.toString() ?? '',
        };
        await tts.setVoice(voiceMap);
      }
    } catch (e) {
      print('⚠️ Error setting dynamic TTS voice: $e');
      try {
        await tts.setLanguage(locale);
      } catch (_) {}
    }
  }
}
