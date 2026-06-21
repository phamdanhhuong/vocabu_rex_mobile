import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class GachaMachineWidget extends StatefulWidget {
  final VoidCallback onSpin;
  final int price;

  const GachaMachineWidget({
    super.key,
    required this.onSpin,
    required this.price,
  });

  @override
  State<GachaMachineWidget> createState() => _GachaMachineWidgetState();
}

class _GachaMachineWidgetState extends State<GachaMachineWidget> {
  bool _isShaking = false;

  void _handleSpin() {
    if (_isShaking) return;
    
    setState(() => _isShaking = true);
    
    // Simulate shaking before triggering the actual open event
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isShaking = false);
        widget.onSpin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gacha Capsule with Shake and Pulse effect
          Stack(
            alignment: Alignment.center,
            children: [
              // Glowing aura
              Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.macaw.withValues(alpha: 0.3),
                      blurRadius: 40.r,
                      spreadRadius: 20.r,
                    )
                  ],
                ),
              ),
              
              // The Capsule
              _isShaking
                  ? Swing(
                      duration: const Duration(milliseconds: 400),
                      infinite: true,
                      child: _buildCapsule(),
                    )
                  : _buildCapsule(),
            ],
          ),
          
          SizedBox(height: 48.h),
          
          // Spin Button
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: GestureDetector(
              onTap: _handleSpin,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.macaw, AppColors.macaw.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.macaw.withValues(alpha: 0.5),
                      blurRadius: 16.r,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'QUAY GACHA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/icons/gem.png', width: 20.w, height: 20.w),
                          SizedBox(width: 6.w),
                          Text(
                            widget.price.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: Text(
              'Có cơ hội nhận khung Avatar cực hiếm!',
              style: TextStyle(
                color: AppColors.wolf,
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule() {
    return Container(
      width: 140.r,
      height: 140.r,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.white,
            AppColors.macaw.withValues(alpha: 0.8),
            AppColors.humpback,
          ],
          stops: const [0.1, 0.6, 1.0],
          center: Alignment.topLeft,
          radius: 1.2,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10.r,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Icon(
          Icons.star_rounded,
          color: Colors.white,
          size: 60.r,
        ),
      ),
    );
  }
}
