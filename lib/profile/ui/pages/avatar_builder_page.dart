import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';

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
      mobileScaffold: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
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
              child: Text(
                'XONG',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.macaw,
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
              FluttermojiCircleAvatar(
                backgroundColor: AppColors.polar,
                radius: 75.r,
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: FluttermojiCustomizer(
                  scaffoldWidth: MediaQuery.of(context).size.width,
                  autosave: true,
                  theme: FluttermojiThemeData(
                    boxDecoration: const BoxDecoration(boxShadow: [BoxShadow()]),
                    primaryBgColor: AppColors.polar,
                    secondaryBgColor: AppColors.snow,
                    iconColor: AppColors.macaw,
                    unselectedIconColor: AppColors.wolf,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
