import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';

class BattleSocketService {
  io.Socket? _socket;
  bool _isConnected = false;

  // Stream controllers
  final _searchingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _matchFoundController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _roundStartController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _damageController = StreamController<Map<String, dynamic>>.broadcast();
  final _koController = StreamController<Map<String, dynamic>>.broadcast();
  final _matchResultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _opponentLeftController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get onSearching => _searchingController.stream;
  Stream<Map<String, dynamic>> get onMatchFound => _matchFoundController.stream;
  Stream<Map<String, dynamic>> get onRoundStart => _roundStartController.stream;
  Stream<Map<String, dynamic>> get onDamage => _damageController.stream;
  Stream<Map<String, dynamic>> get onKO => _koController.stream;
  Stream<Map<String, dynamic>> get onMatchResult =>
      _matchResultController.stream;
  Stream<Map<String, dynamic>> get onOpponentLeft =>
      _opponentLeftController.stream;
  Stream<String> get onError => _errorController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected && _socket != null) return;

    final token = await TokenManager.getAccessToken();
    if (token == null) return;

    // Clean up any previous socket
    _socket?.dispose();

    _socket = io.io(
      '${ApiConfig.socketUrl}/battle',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    // Set up event listeners BEFORE connecting
    _socket!.on('battle:searching', (data) {
      _searchingController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:matchFound', (data) {
      _matchFoundController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:roundStart', (data) {
      _roundStartController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:damage', (data) {
      _damageController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:ko', (data) {
      _koController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:matchResult', (data) {
      _matchResultController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:opponentLeft', (data) {
      _opponentLeftController.add(Map<String, dynamic>.from(data));
    });
    _socket!.on('battle:error', (data) {
      _errorController.add(data['message'] ?? 'Unknown error');
    });

    // Connect and wait for actual connection
    final completer = Completer<void>();

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('Battle socket connected');
      if (!completer.isCompleted) completer.complete();
    });

    _socket!.onConnectError((err) {
      debugPrint('Battle socket connect error: $err');
      if (!completer.isCompleted) {
        completer.completeError('Socket connection failed');
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Battle socket disconnected');
    });

    _socket!.connect();

    // Wait for connection with timeout
    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Battle socket connection timeout');
        throw TimeoutException('Socket connection timeout');
      },
    );
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
    _damageController.close();
    _koController.close();
    _matchResultController.close();
    _opponentLeftController.close();
    _errorController.close();
  }
}
