import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vocabu_rex_mobile/assistant/data/services/voice_call_service.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

// ─── Events ───────────────────────────────────────────

abstract class VoiceCallEvent {}

class StartVoiceCallEvent extends VoiceCallEvent {
  final String? conversationId;
  StartVoiceCallEvent({this.conversationId});
}

class EndVoiceCallEvent extends VoiceCallEvent {}

class ToggleMuteEvent extends VoiceCallEvent {}

class TranscriptReceivedEvent extends VoiceCallEvent {
  final String text;
  final bool isFinal;
  TranscriptReceivedEvent({required this.text, required this.isFinal});
}

class AITextReceivedEvent extends VoiceCallEvent {
  final String text;
  AITextReceivedEvent({required this.text});
}

class AIAudioReceivedEvent extends VoiceCallEvent {
  final String audioBase64;
  final int seq;
  final bool isFinal;
  AIAudioReceivedEvent({
    required this.audioBase64,
    required this.seq,
    required this.isFinal,
  });
}

class CallSummaryReceivedEvent extends VoiceCallEvent {
  final Map<String, dynamic> summary;
  CallSummaryReceivedEvent({required this.summary});
}

class VoiceCallErrorEvent extends VoiceCallEvent {
  final String code;
  final String message;
  VoiceCallErrorEvent({required this.code, required this.message});
}

class ConnectionLostEvent extends VoiceCallEvent {}

// ─── States ───────────────────────────────────────────

abstract class VoiceCallState {}

class VoiceCallIdle extends VoiceCallState {}

class VoiceCallConnecting extends VoiceCallState {}

class VoiceCallActive extends VoiceCallState {
  final String conversationId;
  final bool isMuted;
  final bool isAISpeaking;
  final bool isProcessing;
  final Duration callDuration;
  final List<TranscriptEntry> transcripts;
  final String? currentUserText; // Partial transcript being built

  VoiceCallActive({
    required this.conversationId,
    this.isMuted = false,
    this.isAISpeaking = false,
    this.isProcessing = false,
    this.callDuration = Duration.zero,
    this.transcripts = const [],
    this.currentUserText,
  });

  VoiceCallActive copyWith({
    String? conversationId,
    bool? isMuted,
    bool? isAISpeaking,
    bool? isProcessing,
    Duration? callDuration,
    List<TranscriptEntry>? transcripts,
    String? currentUserText,
  }) {
    return VoiceCallActive(
      conversationId: conversationId ?? this.conversationId,
      isMuted: isMuted ?? this.isMuted,
      isAISpeaking: isAISpeaking ?? this.isAISpeaking,
      isProcessing: isProcessing ?? this.isProcessing,
      callDuration: callDuration ?? this.callDuration,
      transcripts: transcripts ?? this.transcripts,
      currentUserText: currentUserText,
    );
  }
}

class VoiceCallEnded extends VoiceCallState {
  final int durationSeconds;
  final int wordsSpoken;
  final int exchanges;
  final List<TranscriptEntry> transcripts;
  final String conversationId;

  VoiceCallEnded({
    required this.durationSeconds,
    required this.wordsSpoken,
    required this.exchanges,
    required this.transcripts,
    required this.conversationId,
  });
}

class VoiceCallError extends VoiceCallState {
  final String code;
  final String message;
  VoiceCallError({required this.code, required this.message});
}

// ─── Transcript Entry ─────────────────────────────────

class TranscriptEntry {
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;

  TranscriptEntry({required this.role, required this.text, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

// ─── Bloc ─────────────────────────────────────────────

class VoiceCallBloc extends Bloc<VoiceCallEvent, VoiceCallState> {
  final VoiceCallService _voiceService = VoiceCallService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _durationTimer;
  final List<Uint8List> _audioQueue = [];
  bool _isPlayingAudio = false;

  VoiceCallBloc() : super(VoiceCallIdle()) {
    on<StartVoiceCallEvent>(_onStartCall);
    on<EndVoiceCallEvent>(_onEndCall);
    on<ToggleMuteEvent>(_onToggleMute);
    on<TranscriptReceivedEvent>(_onTranscriptReceived);
    on<AITextReceivedEvent>(_onAITextReceived);
    on<AIAudioReceivedEvent>(_onAIAudioReceived);
    on<CallSummaryReceivedEvent>(_onCallSummary);
    on<VoiceCallErrorEvent>(_onError);
    on<ConnectionLostEvent>(_onConnectionLost);
  }

  Future<void> _onStartCall(
    StartVoiceCallEvent event,
    Emitter<VoiceCallState> emit,
  ) async {
    emit(VoiceCallConnecting());

    try {
      // Setup callbacks
      _voiceService.onConnected = (conversationId) {
        add(AITextReceivedEvent(text: '')); // Trigger state update
      };
      _voiceService.onTranscript = (text, isFinal) {
        add(TranscriptReceivedEvent(text: text, isFinal: isFinal));
      };
      _voiceService.onAIText = (text) {
        add(AITextReceivedEvent(text: text));
      };
      _voiceService.onAIAudio = (audio, seq, isFinal) {
        add(
          AIAudioReceivedEvent(audioBase64: audio, seq: seq, isFinal: isFinal),
        );
      };
      _voiceService.onCallSummary = (summary) {
        add(CallSummaryReceivedEvent(summary: summary));
      };
      _voiceService.onError = (code, message) {
        add(VoiceCallErrorEvent(code: code, message: message));
      };
      _voiceService.onDisconnected = () {
        add(ConnectionLostEvent());
      };

      // Connect
      await _voiceService.connect();

      // Get user info and start call
      final userInfo = await TokenManager.getUserInfo();
      final userId = userInfo['userId'] ?? '';

      _voiceService.startCall(
        userId: userId,
        conversationId: event.conversationId,
      );

      // Wait briefly for connection
      await Future.delayed(const Duration(milliseconds: 500));

      // Emit active state
      emit(
        VoiceCallActive(
          conversationId: event.conversationId ?? '',
          transcripts: [],
        ),
      );

      // Start recording
      await _voiceService.startRecording();

      // Start duration timer
      _startDurationTimer();
    } catch (e) {
      emit(VoiceCallError(code: 'START_ERROR', message: e.toString()));
    }
  }

  Future<void> _onEndCall(
    EndVoiceCallEvent event,
    Emitter<VoiceCallState> emit,
  ) async {
    _durationTimer?.cancel();
    await _voiceService.endCall();
    // Wait for summary event, or timeout after 3s
    await Future.delayed(const Duration(seconds: 3));

    if (state is VoiceCallActive) {
      final activeState = state as VoiceCallActive;
      emit(
        VoiceCallEnded(
          durationSeconds: activeState.callDuration.inSeconds,
          wordsSpoken: 0,
          exchanges: activeState.transcripts.length,
          transcripts: activeState.transcripts,
          conversationId: activeState.conversationId,
        ),
      );
    }
    await _voiceService.disconnect();
  }

  void _onToggleMute(ToggleMuteEvent event, Emitter<VoiceCallState> emit) {
    _voiceService.toggleMute();
    if (state is VoiceCallActive) {
      final s = state as VoiceCallActive;
      emit(s.copyWith(isMuted: !s.isMuted));
    }
  }

  void _onTranscriptReceived(
    TranscriptReceivedEvent event,
    Emitter<VoiceCallState> emit,
  ) {
    if (state is VoiceCallActive) {
      final s = state as VoiceCallActive;
      if (event.isFinal) {
        final newTranscripts = [
          ...s.transcripts,
          TranscriptEntry(role: 'user', text: event.text),
        ];
        emit(
          s.copyWith(
            transcripts: newTranscripts,
            currentUserText: null,
            isProcessing: true,
          ),
        );
      } else {
        emit(s.copyWith(currentUserText: event.text));
      }
    }
  }

  void _onAITextReceived(
    AITextReceivedEvent event,
    Emitter<VoiceCallState> emit,
  ) {
    if (state is VoiceCallActive) {
      final s = state as VoiceCallActive;
      if (event.text.isNotEmpty) {
        final newTranscripts = [
          ...s.transcripts,
          TranscriptEntry(role: 'assistant', text: event.text),
        ];
        emit(
          s.copyWith(
            transcripts: newTranscripts,
            isProcessing: false,
            isAISpeaking: true,
          ),
        );
      }
    }
  }

  Future<void> _onAIAudioReceived(
    AIAudioReceivedEvent event,
    Emitter<VoiceCallState> emit,
  ) async {
    try {
      // Decode base64 audio and play
      final audioBytes = base64Decode(event.audioBase64);
      _audioQueue.add(Uint8List.fromList(audioBytes));

      if (!_isPlayingAudio) {
        _playNextInQueue();
      }

      if (event.isFinal && state is VoiceCallActive) {
        // After final audio chunk, mark AI as done speaking
        // (with small delay for playback to finish)
        Future.delayed(const Duration(seconds: 2), () {
          if (state is VoiceCallActive) {
            add(AITextReceivedEvent(text: '')); // Reset speaking state
          }
        });
      }
    } catch (e) {
      // Audio playback error is non-fatal
    }
  }

  Future<void> _playNextInQueue() async {
    if (_audioQueue.isEmpty) {
      _isPlayingAudio = false;
      if (state is VoiceCallActive) {
        final s = state as VoiceCallActive;
        emit(s.copyWith(isAISpeaking: false));
      }
      return;
    }

    _isPlayingAudio = true;
    final audioData = _audioQueue.removeAt(0);

    try {
      // Play the audio using just_audio with a ByteSource
      final source = AudioSource.uri(
        Uri.dataFromBytes(audioData, mimeType: 'audio/wav'),
      );
      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.play();
      await _audioPlayer.processingStateStream.firstWhere(
        (s) => s == ProcessingState.completed,
      );
    } catch (e) {
      // Continue to next audio even if this one fails
    }

    _playNextInQueue();
  }

  void _onCallSummary(
    CallSummaryReceivedEvent event,
    Emitter<VoiceCallState> emit,
  ) {
    _durationTimer?.cancel();
    final summary = event.summary;

    List<TranscriptEntry> transcripts = [];
    if (state is VoiceCallActive) {
      transcripts = (state as VoiceCallActive).transcripts;
    }

    emit(
      VoiceCallEnded(
        durationSeconds: summary['duration'] as int? ?? 0,
        wordsSpoken: summary['wordsSpoken'] as int? ?? 0,
        exchanges: summary['exchanges'] as int? ?? 0,
        transcripts: transcripts,
        conversationId: summary['conversationId'] as String? ?? '',
      ),
    );
  }

  void _onError(VoiceCallErrorEvent event, Emitter<VoiceCallState> emit) {
    emit(VoiceCallError(code: event.code, message: event.message));
  }

  void _onConnectionLost(
    ConnectionLostEvent event,
    Emitter<VoiceCallState> emit,
  ) {
    _durationTimer?.cancel();
    if (state is VoiceCallActive) {
      emit(
        VoiceCallError(
          code: 'CONNECTION_LOST',
          message: 'Voice call connection lost',
        ),
      );
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is VoiceCallActive) {
        final s = state as VoiceCallActive;
        emit(
          s.copyWith(callDuration: s.callDuration + const Duration(seconds: 1)),
        );
      }
    });
  }

  @override
  Future<void> close() async {
    _durationTimer?.cancel();
    await _audioPlayer.dispose();
    await _voiceService.dispose();
    return super.close();
  }
}
