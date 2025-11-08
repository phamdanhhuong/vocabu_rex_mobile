import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _isMicOn = true;
  bool _isCameraOn = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.featherGreen,
        foregroundColor: AppColors.snow,
        elevation: 0,
        title: Text(
          'Video Call',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.snow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Video call area
          Expanded(
            child: Container(
              color: AppColors.wolf.withOpacity(0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_call,
                      size: 120.sp,
                      color: AppColors.featherGreen,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Video Call Feature',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.wolf,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: Text(
                        'Connect with language partners and practice speaking in real-time',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.eel,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.macaw.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '🚧 Coming Soon',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: EdgeInsets.all(24.h),
            decoration: BoxDecoration(
              color: AppColors.snow,
              boxShadow: [
                BoxShadow(
                  color: AppColors.wolf.withOpacity(0.1),
                  blurRadius: 8.r,
                  offset: Offset(0, -2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mic button
                _buildControlButton(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  label: 'Mic',
                  isActive: _isMicOn,
                  onTap: () {
                    setState(() {
                      _isMicOn = !_isMicOn;
                    });
                  },
                ),

                // Camera button
                _buildControlButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  label: 'Camera',
                  isActive: _isCameraOn,
                  onTap: () {
                    setState(() {
                      _isCameraOn = !_isCameraOn;
                    });
                  },
                ),

                // End call button
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'End',
                  isActive: false,
                  color: AppColors.swan,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final buttonColor = color ?? (isActive ? AppColors.featherGreen : AppColors.wolf);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: buttonColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.snow,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.eel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
