import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Duolingo logo
            Padding(
              padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppColors.textWhite,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'duolingo',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content area
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    
                    // Character illustration area
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Main green mascot (Duo) - larger and centered
                            Positioned(
                              bottom: 60.h,
                              right: 60.w,
                              child: Container(
                                width: 140.w,
                                height: 140.h,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(70.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Body
                                    Container(
                                      width: 100.w,
                                      height: 100.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        borderRadius: BorderRadius.circular(50.r),
                                      ),
                                    ),
                                    // Eyes
                                    Positioned(
                                      top: 25.h,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 20.w,
                                            height: 20.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.textWhite,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 8.w,
                                                height: 8.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Container(
                                            width: 20.w,
                                            height: 20.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.textWhite,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 8.w,
                                                height: 8.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Beak
                                    Positioned(
                                      top: 55.h,
                                      child: Container(
                                        width: 12.w,
                                        height: 8.h,
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Floating characters around
                            Positioned(
                              top: 20.h,
                              left: 20.w,
                              child: _buildDuolingoCharacter(
                                AppColors.characterPink,
                                80.w,
                                child: _buildCharacterFace(Colors.black, Colors.pink[200]!),
                              ),
                            ),
                            Positioned(
                              top: 40.h,
                              right: 10.w,
                              child: _buildDuolingoCharacter(
                                AppColors.characterOrange,
                                70.w,
                                child: _buildCharacterFace(Colors.brown, Colors.orange[200]!),
                              ),
                            ),
                            Positioned(
                              bottom: 120.h,
                              left: 30.w,
                              child: _buildDuolingoCharacter(
                                AppColors.characterBlue,
                                75.w,
                                child: _buildCharacterFace(Colors.white, Colors.blue[200]!),
                              ),
                            ),
                            Positioned(
                              top: 80.h,
                              left: 120.w,
                              child: _buildDuolingoCharacter(
                                AppColors.characterYellow,
                                65.w,
                                child: _buildCharacterFace(Colors.black, Colors.yellow[200]!),
                              ),
                            ),
                            Positioned(
                              bottom: 140.h,
                              right: 20.w,
                              child: _buildDuolingoCharacter(
                                AppColors.characterPurple,
                                70.w,
                                child: _buildCharacterFace(Colors.white, Colors.purple[200]!),
                              ),
                            ),

                            // Phone with coins
                            Positioned(
                              bottom: 20.h,
                              left: 50.w,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Container(
                                  width: 90.w,
                                  height: 140.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.textWhite,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: Colors.grey[300]!, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Screen
                                      Positioned(
                                        top: 15.h,
                                        left: 8.w,
                                        right: 8.w,
                                        bottom: 25.h,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [AppColors.primaryGreen, Colors.green[300]!],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                        ),
                                      ),
                                      // Coins floating around
                                      ...List.generate(3, (index) => Positioned(
                                        top: 10.h + (index * 20.h),
                                        right: -10.w + (index * 5.w),
                                        child: Container(
                                          width: 16.w,
                                          height: 16.h,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow[600],
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.yellow.withOpacity(0.4),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Welcome text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        'The free, fun, and effective way to learn a language!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[700],
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        backgroundColor: Colors.grey[50],
                        side: BorderSide(color: Colors.grey[300]!, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'I ALREADY HAVE AN ACCOUNT',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuolingoCharacter(Color backgroundColor, double size, {Widget? child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child ?? Center(
        child: Icon(
          Icons.face,
          color: AppColors.textWhite,
          size: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildCharacterFace(Color eyeColor, Color skinColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Face base
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: skinColor,
            shape: BoxShape.circle,
          ),
        ),
        // Eyes
        Positioned(
          top: 15.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: eyeColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: eyeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        // Smile
        Positioned(
          bottom: 15.h,
          child: Container(
            width: 16.w,
            height: 8.h,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: eyeColor,
                  width: 2,
                ),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}