import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vocabu_rex_mobile/network/api_constants.dart';

/// Service for managing voice call WebSocket connections and audio streaming.
class VoiceCallService {
  IO.Socket? _socket;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription? _recordSubscription;

  bool _isConnected = false;
  bool _isMuted = false;
  int _audioSeq = 0;

  // Callbacks
  Function(String text, bool isFinal)? onTranscript;
  Function(String text)? onAIText;
  Function(String audioBase64, int seq, bool isFinal)? onAIAudio;
  Function(Map<String, dynamic> summary)? onCallSummary;
  Function(String conversationId)? onConnected;
  Function(String code, String message)? onError;
  Function()? onDisconnected;

  bool get isConnected => _isConnected;
  bool get isMuted => _isMuted;

  /// Connect to the voice call WebSocket
  Future<void> connect() async {
    try {
      final wsUrl = ApiEndpoints.baseUrl; // http://localhost:3000

      _socket = IO.io(
        '$wsUrl/voice',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableForceNewConnection()
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        onDisconnected?.call();
      });

      _socket!.onConnectError((error) {
        onError?.call('CONNECTION_ERROR', error.toString());
      });

      // Listen for server events
      _socket!.on('voice:connected', (data) {
        final conversationId = data['conversationId'] as String? ?? '';
        onConnected?.call(conversationId);
      });

      _socket!.on('voice:transcript', (data) {
        final text = data['text'] as String? ?? '';
        final isFinal = data['isFinal'] as bool? ?? true;
        onTranscript?.call(text, isFinal);
      });

      _socket!.on('voice:ai-text', (data) {
        final text = data['text'] as String? ?? '';
        onAIText?.call(text);
      });

      _socket!.on('voice:ai-audio', (data) {
        final audio = data['audio'] as String? ?? '';
        final seq = data['seq'] as int? ?? 0;
        final isFinal = data['isFinal'] as bool? ?? false;
        onAIAudio?.call(audio, seq, isFinal);
      });

      _socket!.on('voice:summary', (data) {
        if (data is Map<String, dynamic>) {
          onCallSummary?.call(data);
        }
      });

      _socket!.on('voice:error', (data) {
        final code = data['code'] as String? ?? 'UNKNOWN';
        final message = data['message'] as String? ?? 'Unknown error';
        onError?.call(code, message);
      });

      _socket!.connect();
    } catch (e) {
      onError?.call('CONNECT_ERROR', e.toString());
    }
  }

  /// Start a voice call by emitting voice:start event
  void startCall({required String userId, String? conversationId}) {
    _audioSeq = 0;
    _socket?.emit('voice:start', {
      'userId': userId,
      'conversationId': conversationId,
    });
  }

  /// Start recording audio from microphone and streaming via WebSocket
  Future<void> startRecording() async {
    if (_isMuted) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      onError?.call('PERMISSION_DENIED', 'Microphone permission denied');
      return;
    }

    try {
      // Stream PCM audio at 16kHz mono
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
      );

      _recordSubscription = stream.listen((data) {
        if (!_isMuted && _isConnected) {
          _audioSeq++;
          final audioBase64 = base64Encode(data);
          _socket?.emit('voice:audio', {
            'audio': audioBase64,
            'seq': _audioSeq,
          });
        }
      });
    } catch (e) {
      onError?.call('RECORD_ERROR', e.toString());
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  /// Toggle mute
  void toggleMute() {
    _isMuted = !_isMuted;
  }

  /// End the voice call
  Future<void> endCall() async {
    await stopRecording();
    _socket?.emit('voice:end', {});
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    await stopRecording();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await disconnect();
    _recorder.dispose();
  }
}
