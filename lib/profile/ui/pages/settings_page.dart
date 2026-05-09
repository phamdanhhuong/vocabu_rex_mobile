import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/edit_profile_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/change_password_page.dart';

/// Trang cài đặt với giao diện giống Duolingo
class SettingsPage extends StatefulWidget {
  final VoidCallback? onDone;

  const SettingsPage({super.key, this.onDone});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppPreferences _prefs = AppPreferences();
  late bool _isDarkModePending;

  @override
  void initState() {
    super.initState();
    _isDarkModePending = _prefs.isDarkMode;
  }

  @override
  void dispose() {
    if (_isDarkModePending != _prefs.isDarkMode) {
      _prefs.setDarkMode(_isDarkModePending);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WebPageWrapper(
      mobileScaffold: Scaffold(
        backgroundColor: AppColors.snow,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Tài khoản Section
                    _buildSectionTitle('Tài khoản', theme),
                    _buildSettingsList([
                      _SettingItem(
                        title: 'Hồ sơ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        title: 'Đổi mật khẩu',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        title: 'Xóa tài khoản',
                        textColor: Colors.red,
                        onTap: () => _handleDeleteAccount(context),
                      ),
                    ]),

                    SizedBox(height: 24.h),

                    // Khóa học Section
                    _buildSectionTitle('Khóa học', theme),
                    _buildSettingsList([
                      _SettingItem(
                        title: 'Mục tiêu hàng ngày',
                        onTap: () {
                          _showDailyGoalBottomSheet(context);
                        },
                      ),
                      _SettingItem(
                        title: 'Trình độ hiện tại',
                        onTap: () {
                          _showProficiencyBottomSheet(context);
                        },
                      ),
                    ]),

                    SizedBox(height: 24.h),

                    // Trải nghiệm Section
                    _buildSectionTitle('Trải nghiệm', theme),
                    _buildSettingsContainer([
                      _buildSwitchItem(
                        title: 'Hiệu ứng âm thanh',
                        value: _prefs.isSoundEnabled,
                        onChanged: (val) async {
                          await _prefs.setSoundEnabled(val);
                          setState(() {});
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.swan,
                        indent: 16.w,
                        endIndent: 16.w,
                      ),
                      _buildSwitchItem(
                        title: 'Rung',
                        value: _prefs.isHapticsEnabled,
                        onChanged: (val) async {
                          await _prefs.setHapticsEnabled(val);
                          setState(() {});
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.swan,
                        indent: 16.w,
                        endIndent: 16.w,
                      ),
                      _buildSwitchItem(
                        title: 'Giao diện tối (Dark mode)',
                        value: _isDarkModePending,
                        onChanged: (val) {
                          setState(() {
                            _isDarkModePending = val;
                          });
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.swan,
                        indent: 16.w,
                        endIndent: 16.w,
                      ),
                      _buildSwitchItem(
                        title: 'Tốc độ đọc chậm',
                        value: !_prefs.isVoiceSpeedNormal,
                        onChanged: (val) async {
                          await _prefs.setVoiceSpeedNormal(!val);
                          setState(() {});
                        },
                      ),
                    ]),

                    SizedBox(height: 24.h),

                    // Hỗ trợ Section
                    _buildSectionTitle('Hỗ trợ', theme),
                    _buildSettingsList([
                      _SettingItem(title: 'Trung tâm trợ giúp', onTap: () {}),
                      _SettingItem(title: 'Phản hồi', onTap: () {}),
                    ]),

                    SizedBox(height: 32.h),

                    // Logout Button
                    _buildLogoutButton(context),

                    SizedBox(height: 32.h),

                    // Footer links
                    _buildFooterLinks(context),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.snow,
        border: Border(
          bottom: BorderSide(color: AppColors.swan, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
            ),
          ),
          TextButton(
            onPressed: () {
              if (_isDarkModePending != _prefs.isDarkMode) {
                _prefs.setDarkMode(_isDarkModePending);
              }
              if (widget.onDone != null) {
                widget.onDone!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'HOÀN TẤT',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.macaw,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.bodyText,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.swan, width: 2),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsList(List<_SettingItem> items) {
    return _buildSettingsContainer(
      items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return Column(
          children: [
            _buildSettingItem(item),
            if (!isLast)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.swan,
                indent: 16.w,
                endIndent: 16.w,
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSettingItem(_SettingItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: item.textColor ?? AppColors.bodyText,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.macaw,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: OutlinedButton(
          onPressed: () => _handleLogout(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.macaw,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.macaw, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            'ĐĂNG XUẤT',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildFooterLink('ĐIỀU KHOẢN', () {}),
          SizedBox(height: 16.h),
          _buildFooterLink('CHÍNH SÁCH BẢO MẬT', () {}),
          SizedBox(height: 16.h),
          _buildFooterLink('LỜI CẢM ƠN', () {}),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.macaw,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xóa tài khoản',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Hành động này không thể hoàn tác. Mọi tiến trình học tập, XP và bạn bè sẽ bị xóa vĩnh viễn. Bạn có chắc chắn muốn xóa?',
          style: TextStyle(fontSize: 16.sp),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'HỦY',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'XÓA VĨNH VIỄN',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await AuthService().deleteAccount();
        await TokenManager.clearAllTokens();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa tài khoản: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(fontSize: 16.sp),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'HỦY',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'ĐĂNG XUẤT',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.macaw,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        await TokenManager.clearAllTokens();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi đăng xuất: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDailyGoalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Mục tiêu hàng ngày',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Thư giãn (5 phút/ngày)'),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 5),
              ),
              ListTile(
                title: const Text('Bình thường (10 phút/ngày)'),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 10),
              ),
              ListTile(
                title: const Text('Nghiêm túc (15 phút/ngày)'),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 15),
              ),
              ListTile(
                title: const Text('Rất chăm chỉ (30 phút/ngày)'),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 30),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProficiencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Trình độ hiện tại',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Người mới bắt đầu (Beginner)'),
                onTap: () =>
                    _updatePreferences(context, proficiencyLevel: 'BEGINNER'),
              ),
              ListTile(
                title: const Text('Sơ cấp (Elementary)'),
                onTap: () =>
                    _updatePreferences(context, proficiencyLevel: 'ELEMENTARY'),
              ),
              ListTile(
                title: const Text('Trung cấp (Intermediate)'),
                onTap: () => _updatePreferences(
                  context,
                  proficiencyLevel: 'INTERMEDIATE',
                ),
              ),
              ListTile(
                title: const Text('Cao cấp (Advanced)'),
                onTap: () =>
                    _updatePreferences(context, proficiencyLevel: 'ADVANCED'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updatePreferences(
    BuildContext context, {
    int? dailyGoalMinutes,
    String? proficiencyLevel,
  }) async {
    Navigator.pop(context); // Close bottom sheet
    try {
      await AuthService().updatePreferences(
        dailyGoalMinutes: dailyGoalMinutes,
        proficiencyLevel: proficiencyLevel,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _SettingItem {
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  _SettingItem({required this.title, required this.onTap, this.textColor});
}
