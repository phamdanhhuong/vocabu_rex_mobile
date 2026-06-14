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
      backgroundColor: AppColors.snow,
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
            Text(
              'Đang kết nối với Rex...',
              style: TextStyle(
                color: AppColors.eel,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gia sư AI của bạn',
              style: TextStyle(
                color: AppColors.wolf,
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
      backgroundColor: AppColors.snow,
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
                      ? AppColors.bee
                      : AppColors.featherGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                state.isAISpeaking
                    ? 'Rex đang nói...'
                    : state.isProcessing
                    ? 'Đang suy nghĩ...'
                    : 'Đang nghe...',
                style: TextStyle(
                  color: AppColors.wolf,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Duration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.polar,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.swan),
            ),
            child: Text(
              _formatDuration(state.callDuration),
              style: TextStyle(
                color: AppColors.eel,
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
                color: AppColors.polar,
                border: Border.all(color: AppColors.swan, width: 2),
                boxShadow: [
                  BoxShadow(
                    color:
                        (state.isAISpeaking
                                ? AppColors.featherGreen
                                : AppColors.macaw)
                            .withOpacity(0.3),
                    blurRadius: state.isAISpeaking ? 30 : 15,
                    spreadRadius: state.isAISpeaking ? 5 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 64,
                  color: AppColors.macaw,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rex',
            style: TextStyle(
              color: AppColors.eel,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gia sư tiếng Anh AI',
            style: TextStyle(
              color: AppColors.wolf,
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
        color: AppColors.polar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.swan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.subtitles,
                color: AppColors.wolf,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Phụ đề trực tiếp',
                style: TextStyle(
                  color: AppColors.wolf,
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.macaw : AppColors.snow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser ? null : Border.all(color: AppColors.swan, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.hare.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : AppColors.eel,
            fontSize: 14,
            height: 1.4,
            fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls(VoiceCallActive state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.polar,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.swan),
          boxShadow: [
            BoxShadow(
              color: AppColors.hare.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button
            _buildControlButton(
              icon: state.isMuted ? Icons.mic_off : Icons.mic,
              label: state.isMuted ? 'Mở mic' : 'Tắt mic',
              color: state.isMuted ? AppColors.cardinal : AppColors.swan,
              iconColor: state.isMuted ? Colors.white : AppColors.eel,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardinal,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardinal.withOpacity(0.3),
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
              label: 'Loa ngoài',
              color: AppColors.swan,
              iconColor: AppColors.eel,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
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
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.wolf,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Post Call Review Screen ──────────────────────

  Widget _buildPostCallScreen(VoiceCallEnded state) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Text(
              'Đã kết thúc',
              style: TextStyle(
                color: AppColors.eel,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Buổi luyện tập tuyệt vời! 🎉',
              style: TextStyle(
                color: AppColors.wolf,
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
                    label: 'Thời gian',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.chat_bubble,
                    value: '${state.exchanges}',
                    label: 'Số lượt',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.text_fields,
                    value: '${state.wordsSpoken}',
                    label: 'Số từ',
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
                    color: AppColors.wolf,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch sử cuộc gọi',
                    style: TextStyle(
                      color: AppColors.wolf,
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
                    backgroundColor: AppColors.macaw,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Hoàn thành',
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
          color: AppColors.polar,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.swan),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.macaw, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppColors.eel,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.wolf,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUser
                  ? AppColors.macaw.withOpacity(0.1)
                  : AppColors.polar,
              border: Border.all(color: AppColors.swan),
            ),
            child: Center(
              child: Icon(
                isUser ? Icons.person : Icons.smart_toy_rounded,
                color: isUser ? AppColors.macaw : AppColors.featherGreen,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'Bạn' : 'Rex',
                  style: TextStyle(
                    color: isUser ? AppColors.macaw : AppColors.featherGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.snow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.swan),
                  ),
                  child: Text(
                    entry.text,
                    style: TextStyle(
                      color: AppColors.eel,
                      fontSize: 14,
                    ),
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
      backgroundColor: AppColors.snow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.cardinal, size: 64),
            const SizedBox(height: 16),
            Text(
              'Lỗi Cuộc Gọi',
              style: TextStyle(
                color: AppColors.eel,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                color: AppColors.wolf,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.macaw,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Quay lại',
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
