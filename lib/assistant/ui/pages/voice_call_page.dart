import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/voice_call_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Full-screen voice call page inspired by Duolingo Max video call.
/// Features: AI avatar with animations, live transcript, waveform, call controls.
class VoiceCallPage extends StatefulWidget {
  final String? conversationId;

  const VoiceCallPage({super.key, this.conversationId});

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  final ScrollController _transcriptScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Pulse animation for AI avatar
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Start the call
    context.read<VoiceCallBloc>().add(
      StartVoiceCallEvent(conversationId: widget.conversationId),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _transcriptScrollController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceCallBloc, VoiceCallState>(
      listener: (context, state) {
        if (state is VoiceCallActive) {
          // Auto-scroll transcript
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_transcriptScrollController.hasClients) {
              _transcriptScrollController.animateTo(
                _transcriptScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      builder: (context, state) {
        if (state is VoiceCallConnecting) {
          return _buildConnectingScreen();
        }
        if (state is VoiceCallActive) {
          return _buildActiveCallScreen(state);
        }
        if (state is VoiceCallEnded) {
          return _buildPostCallScreen(state);
        }
        if (state is VoiceCallError) {
          return _buildErrorScreen(state);
        }
        return _buildConnectingScreen();
      },
    );
  }

  // ─── Connecting Screen ────────────────────────────

  Widget _buildConnectingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated connecting indicator
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.featherGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connecting to Rex...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI English tutor',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Active Call Screen ───────────────────────────

  Widget _buildActiveCallScreen(VoiceCallActive state) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: duration + status
            _buildTopBar(state),

            // AI Avatar area (takes most space)
            Expanded(flex: 3, child: _buildAIAvatar(state)),

            // Live transcript area
            Expanded(flex: 2, child: _buildTranscriptArea(state)),

            // Call controls
            _buildCallControls(state),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(VoiceCallActive state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Status indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.isProcessing
                      ? Colors.amber
                      : AppColors.featherGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.isAISpeaking
                    ? 'Rex is speaking...'
                    : state.isProcessing
                    ? 'Thinking...'
                    : 'Listening...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          // Duration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatDuration(state.callDuration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar(VoiceCallActive state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar with pulse animation when speaking
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = state.isAISpeaking ? _pulseAnimation.value : 1.0;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.featherGreen, AppColors.macaw],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (state.isAISpeaking
                                ? AppColors.featherGreen
                                : AppColors.macaw)
                            .withOpacity(0.4),
                    blurRadius: state.isAISpeaking ? 30 : 15,
                    spreadRadius: state.isAISpeaking ? 5 : 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🦖', style: TextStyle(fontSize: 64)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rex',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI English Tutor',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),

          // Waveform when AI is speaking
          if (state.isAISpeaking) ...[
            const SizedBox(height: 16),
            _buildWaveform(),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 40,
          child: CustomPaint(
            painter: _WaveformPainter(
              progress: _waveController.value,
              color: AppColors.featherGreen,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranscriptArea(VoiceCallActive state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.subtitles,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Live Transcript',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _transcriptScrollController,
              itemCount:
                  state.transcripts.length +
                  (state.currentUserText != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.transcripts.length &&
                    state.currentUserText != null) {
                  // Partial user transcript
                  return _buildTranscriptBubble(
                    text: '${state.currentUserText}...',
                    isUser: true,
                    isPartial: true,
                  );
                }
                final entry = state.transcripts[index];
                return _buildTranscriptBubble(
                  text: entry.text,
                  isUser: entry.role == 'user',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBubble({
    required String text,
    required bool isUser,
    bool isPartial = false,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.macaw.withOpacity(isPartial ? 0.5 : 0.8)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(isPartial ? 0.7 : 1.0),
            fontSize: 14,
            fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls(VoiceCallActive state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: state.isMuted ? Icons.mic_off : Icons.mic,
            label: state.isMuted ? 'Unmute' : 'Mute',
            color: state.isMuted ? Colors.red : Colors.white.withOpacity(0.2),
            onTap: () {
              context.read<VoiceCallBloc>().add(ToggleMuteEvent());
            },
          ),

          // End call button (big red)
          GestureDetector(
            onTap: () {
              context.read<VoiceCallBloc>().add(EndVoiceCallEvent());
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40FF0000),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.call_end, color: Colors.white, size: 32),
            ),
          ),

          // Speaker button
          _buildControlButton(
            icon: Icons.volume_up,
            label: 'Speaker',
            color: Colors.white.withOpacity(0.2),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Post Call Review Screen ──────────────────────

  Widget _buildPostCallScreen(VoiceCallEnded state) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            const Text(
              'Call Ended',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great practice session! 🎉',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.timer,
                    value: _formatDuration(
                      Duration(seconds: state.durationSeconds),
                    ),
                    label: 'Duration',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.chat_bubble,
                    value: '${state.exchanges}',
                    label: 'Exchanges',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.text_fields,
                    value: '${state.wordsSpoken}',
                    label: 'Words',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transcript review
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Conversation Transcript',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.transcripts.length,
                itemBuilder: (context, index) {
                  final entry = state.transcripts[index];
                  return _buildReviewTranscriptItem(entry);
                },
              ),
            ),

            // Done button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.featherGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.featherGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTranscriptItem(TranscriptEntry entry) {
    final isUser = entry.role == 'user';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUser
                  ? AppColors.macaw.withOpacity(0.3)
                  : AppColors.featherGreen.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                isUser ? '👤' : '🦖',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Rex',
                  style: TextStyle(
                    color: isUser ? AppColors.macaw : AppColors.featherGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error Screen ─────────────────────────────────

  Widget _buildErrorScreen(VoiceCallError state) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Call Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.featherGreen,
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Waveform Painter ───────────────────────────────

class _WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;

  _WaveformPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barCount = 20;
    final barWidth = size.width / (barCount * 2);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth * 2) + barWidth / 2;
      final phase = (i / barCount + progress) * 2 * pi;
      final height =
          (sin(phase) * 0.5 + 0.5) * size.height * 0.8 + size.height * 0.1;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, size.height / 2),
          width: barWidth,
          height: height,
        ),
        Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
