import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

/// Trang cài đặt với giao diện giống Duolingo
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
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
                        title: 'Cài đặt riêng',
                        onTap: () {
                          // TODO: Navigate to privacy settings
                        },
                      ),
                      _SettingItem(
                        title: 'Hồ sơ',
                        onTap: () {
                          // TODO: Navigate to profile settings
                        },
                      ),
                      _SettingItem(
                        title: 'Thông báo',
                        onTap: () {
                          // TODO: Navigate to notification settings
                        },
                      ),
                      _SettingItem(
                        title: 'Khoá học',
                        onTap: () {
                          // TODO: Navigate to course settings
                        },
                      ),
                      _SettingItem(
                        title: 'Duolingo for Schools',
                        onTap: () {
                          // TODO: Navigate to schools settings
                        },
                      ),
                      _SettingItem(
                        title: 'Cài đặt quyền riêng tư',
                        onTap: () {
                          // TODO: Navigate to privacy rights settings
                        },
                      ),
                    ]),
                    
                    SizedBox(height: 24.h),
                    
                    // Hỗ trợ Section
                    _buildSectionTitle('Hỗ trợ', theme),
                    _buildSettingsList([
                      _SettingItem(
                        title: 'Trung tâm trợ giúp',
                        onTap: () {
                          // TODO: Navigate to help center
                        },
                      ),
                      _SettingItem(
                        title: 'Phản hồi',
                        onTap: () {
                          // TODO: Navigate to feedback
                        },
                      ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
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
              Navigator.pop(context);
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

  Widget _buildSettingsList(List<_SettingItem> items) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
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
                  color: Colors.grey[200],
                  indent: 16.w,
                  endIndent: 16.w,
                ),
            ],
          );
        }).toList(),
      ),
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
                color: AppColors.bodyText,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24.sp,
            ),
          ],
        ),
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
            side: BorderSide(color: AppColors.macaw, width: 2),
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
          _buildFooterLink(
            'ĐIỀU KHOẢN',
            () {
              // TODO: Navigate to terms
            },
          ),
          SizedBox(height: 16.h),
          _buildFooterLink(
            'CHÍNH SÁCH BẢO MẬT',
            () {
              // TODO: Navigate to privacy policy
            },
          ),
          SizedBox(height: 16.h),
          _buildFooterLink(
            'LỜI CẢM ƠN',
            () {
              // TODO: Navigate to acknowledgments
            },
          ),
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

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(
            fontSize: 16.sp,
          ),
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
        // Clear all tokens and user data
        await TokenManager.clearAllTokens();
        
        // Navigate to welcome page and remove all previous routes
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
}

/// Model cho mỗi setting item
class _SettingItem {
  final String title;
  final VoidCallback onTap;

  _SettingItem({
    required this.title,
    required this.onTap,
  });
}
