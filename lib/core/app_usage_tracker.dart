import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageTracker extends WidgetsBindingObserver {
  static final AppUsageTracker _instance = AppUsageTracker._internal();
  factory AppUsageTracker() => _instance;
  AppUsageTracker._internal();

  DateTime? _lastResumedTime;
  Timer? _syncTimer;
  
  static const MethodChannel _channel = MethodChannel('com.tlcn.vocaburex/native_service');

  bool get _canUseNativeChannel => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  void init() {
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _lastResumedTime = DateTime.now();
    }
    // Set up a periodic timer to sync every 1 minute while active
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_lastResumedTime != null) {
        _updateUsageTime();
      }
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lastResumedTime = DateTime.now();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      if (_lastResumedTime != null) {
        _updateUsageTime();
        _lastResumedTime = null;
      }
    }
  }

  Future<void> _updateUsageTime() async {
    if (_lastResumedTime == null) return;

    final now = DateTime.now();
    final duration = now.difference(_lastResumedTime!);
    if (duration.inSeconds < 1) return; // ignore sub-second intervals

    _lastResumedTime = now; // reset the tracker

    final prefs = await SharedPreferences.getInstance();
    
    // Get current date string (YYYY-MM-DD)
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final savedDate = prefs.getString('last_usage_date');
    
    int todaySeconds = 0;
    if (savedDate == dateKey) {
      todaySeconds = prefs.getInt('today_usage_seconds') ?? 0;
    }

    todaySeconds += duration.inSeconds;
    
    await prefs.setString('last_usage_date', dateKey);
    await prefs.setInt('today_usage_seconds', todaySeconds);

    // Sync to native if possible
    if (_canUseNativeChannel) {
      try {
        final activityData = {
          'todayMinutes': todaySeconds ~/ 60,
          'date': dateKey,
        };
        await _channel.invokeMethod('syncActivity', {'data': jsonEncode(activityData)});
      } catch (e) {
        debugPrint('Failed to sync activity to native: $e');
      }
    }
  }

  // Force sync from other places (like HomeBloc when user loads XP)
  Future<void> syncAdditionalActivity({
    int? todayXp,
    int? lessonsCount,
  }) async {
    if (!_canUseNativeChannel) return;
    
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    int todaySeconds = 0;
    if (prefs.getString('last_usage_date') == dateKey) {
      todaySeconds = prefs.getInt('today_usage_seconds') ?? 0;
    }

    try {
      final activityData = {
        'todayMinutes': todaySeconds ~/ 60,
        'date': dateKey,
        if (todayXp != null) 'todayXp': todayXp,
        if (lessonsCount != null) 'lessonsCount': lessonsCount,
      };
      await _channel.invokeMethod('syncActivity', {'data': jsonEncode(activityData)});
    } catch (e) {
      debugPrint('Failed to sync additional activity to native: $e');
    }
  }
}
