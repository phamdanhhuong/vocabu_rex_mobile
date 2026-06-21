import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';

class AvatarBuilderPage extends StatefulWidget {
  final String? initialUrl; // Now technically initialString, but keeping name for compatibility

  const AvatarBuilderPage({super.key, this.initialUrl});

  @override
  State<AvatarBuilderPage> createState() => _AvatarBuilderPageState();
}

class _AvatarBuilderPageState extends State<AvatarBuilderPage> {
  @override
  void initState() {
    super.initState();
    // If we have an initial string, we can try to restore fluttermoji state
    // Fluttermoji uses SharedPreferences to restore its own state automatically.
    // So if the user edits their own avatar, it will be loaded.
  }

  Future<void> _handleSave() async {
    // Encode the current SVG state to a string to save
    final newAvatarString = await FluttermojiFunctions().encodeMySVGtoString();
    if (mounted) {
      Navigator.pop(context, newAvatarString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebPageWrapper(
      mobileScaffold: StaticSpaceBackground(
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.bodyText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Tạo Avatar',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.bodyText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _handleSave,
              child: Shimmer.fromColors(
                baseColor: AppColors.macaw,
                highlightColor: Colors.yellowAccent,
                period: const Duration(seconds: 2),
                child: Text(
                  'XONG',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.macaw,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              ElasticIn(
                duration: const Duration(milliseconds: 1500),
                child: _FloatingAvatarWrapper(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.fox.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppColors.macaw.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple gradient studio background
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(4), // Give it a slight border look
                    child: FluttermojiCircleAvatar(
                      backgroundColor: Colors.transparent, // Let gradient show through
                      radius: 75.r,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 800),
                  child: FluttermojiCustomizer(
                    scaffoldWidth: MediaQuery.of(context).size.width,
                    autosave: true,
                    theme: FluttermojiThemeData(
                      boxDecoration: const BoxDecoration(boxShadow: [BoxShadow()]),
                      primaryBgColor: AppColors.polar,
                      secondaryBgColor: AppColors.snow,
                      iconColor: AppColors.macaw,
                      unselectedIconColor: AppColors.wolf,
                      labelTextStyle: TextStyle(
                        color: AppColors.bodyText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _FloatingAvatarWrapper extends StatefulWidget {
  final Widget child;
  const _FloatingAvatarWrapper({required this.child});

  @override
  State<_FloatingAvatarWrapper> createState() => _FloatingAvatarWrapperState();
}

class _FloatingAvatarWrapperState extends State<_FloatingAvatarWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
