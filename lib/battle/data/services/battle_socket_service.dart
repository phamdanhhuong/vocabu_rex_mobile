import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';

class BattleSocketService {
  IO.Socket? _socket;
  bool _isConnected = false;

  // Stream controllers for events
  final _searchingController = StreamController<Map<String, dynamic>>.broadcast();
  final _matchFoundController = StreamController<Map<String, dynamic>>.broadcast();
  final _roundStartController = StreamController<Map<String, dynamic>>.broadcast();
  final _opponentAnsweredController = StreamController<void>.broadcast();
  final _roundResultController = StreamController<Map<String, dynamic>>.broadcast();
  final _matchResultController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get onSearching => _searchingController.stream;
  Stream<Map<String, dynamic>> get onMatchFound => _matchFoundController.stream;
  Stream<Map<String, dynamic>> get onRoundStart => _roundStartController.stream;
  Stream<void> get onOpponentAnswered => _opponentAnsweredController.stream;
  Stream<Map<String, dynamic>> get onRoundResult => _roundResultController.stream;
  Stream<Map<String, dynamic>> get onMatchResult => _matchResultController.stream;
  Stream<String> get onError => _errorController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    final token = await TokenManager.getAccessToken();
    if (token == null) return;

    _socket = IO.io(
      '${ApiEndpoints.baseUrl}/battle',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('Battle socket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Battle socket disconnected');
    });

    // Listen for events
    _socket!.on('battle:searching', (data) {
      _searchingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('battle:matchFound', (data) {
      _matchFoundController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('battle:roundStart', (data) {
      _roundStartController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('battle:opponentAnswered', (_) {
      _opponentAnsweredController.add(null);
    });

    _socket!.on('battle:roundResult', (data) {
      _roundResultController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('battle:matchResult', (data) {
      _matchResultController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('battle:error', (data) {
      _errorController.add(data['message'] ?? 'Unknown error');
    });

    _socket!.connect();
  }

  void findMatch() {
    _socket?.emit('battle:findMatch', {});
  }

  void cancelSearch() {
    _socket?.emit('battle:cancelSearch', {});
  }

  void submitAnswer({
    required String matchId,
    required int roundNumber,
    required String answer,
    required int timeMs,
  }) {
    _socket?.emit('battle:submitAnswer', {
      'matchId': matchId,
      'roundNumber': roundNumber,
      'answer': answer,
      'timeMs': timeMs,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _searchingController.close();
    _matchFoundController.close();
    _roundStartController.close();
    _opponentAnsweredController.close();
    _roundResultController.close();
    _matchResultController.close();
    _errorController.close();
  }
}
