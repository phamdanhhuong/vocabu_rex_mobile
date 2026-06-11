import 'package:vocabu_rex_mobile/profile/ui/widgets/auto_scroll_dialog.dart';
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
                        title: 'Ẩn lịch sử đấu (Public)',
                        value: _prefs.hideBattleHistory,
                        onChanged: (val) async {
                          await _prefs.setHideBattleHistory(val);
                          setState(() {});
                          try {
                            await AuthService().updatePreferences(hideBattleHistory: val);
                          } catch (e) {
                            // rollback if fails silently
                            await _prefs.setHideBattleHistory(!val);
                            setState(() {});
                          }
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
          _buildFooterLink('ĐIỀU KHOẢN', () {
            showDialog(
              context: context,
              builder: (_) => const AutoScrollDialog(
                title: 'Điều khoản',
                content: 'ĐIỀU KHOẢN SỬ DỤNG VOCABUREX\n\n'
                    'Chào mừng bạn đến với VocabuRex - Ứng dụng học từ vựng tiếng Anh giao tiếp đỉnh cao!\n\n'
                    '--- PHẦN 1: TỔNG QUAN ---\n'
                    'Bằng việc tải xuống, cài đặt và sử dụng VocabuRex, bạn đồng ý vô điều kiện với tất cả các điều khoản và điều kiện được nêu tại đây. Nếu bạn không đồng ý với bất kỳ phần nào của các điều khoản này, vui lòng gỡ cài đặt ứng dụng ngay lập tức.\n\n'
                    '--- PHẦN 2: TÀI KHOẢN CỦA BẠN ---\n'
                    'Khi tạo tài khoản, bạn phải cung cấp thông tin chính xác và cập nhật. Bạn hoàn toàn chịu trách nhiệm bảo mật mật khẩu và tài khoản của mình. Mọi hoạt động dưới tài khoản của bạn đều do bạn chịu trách nhiệm pháp lý.\n\n'
                    '--- PHẦN 3: QUYỀN SỞ HỮU TRÍ TUỆ ---\n'
                    'Tất cả nội dung (hình ảnh, bài tập, câu hỏi, logic trò chơi) đều thuộc bản quyền của VocabuRex. Nghiêm cấm mọi hành vi sao chép, dịch ngược, hoặc sử dụng vì mục đích thương mại mà không có sự cho phép bằng văn bản.\n\n'
                    '--- PHẦN 4: THI ĐẤU & HÀNH VI ---\n'
                    'Trong tính năng Thi đấu trực tuyến (Arena), người chơi phải tôn trọng đối thủ. Bất kỳ hành vi sử dụng phần mềm thứ ba để gian lận, phá hoại hệ thống, hay sử dụng từ ngữ xúc phạm đều sẽ dẫn đến việc khóa tài khoản vĩnh viễn.\n\n'
                    '--- PHẦN 5: TỪ CHỐI BẢO ĐẢM ---\n'
                    'VocabuRex không đảm bảo rằng ứng dụng sẽ hoàn toàn không có lỗi hoặc không bị gián đoạn. Chúng tôi có quyền tạm ngừng dịch vụ để bảo trì mà không cần báo trước.\n\n'
                    'Chúc bạn có những giờ phút học tập thật hiệu quả và vui vẻ cùng VocabuRex!',
              ),
            );
          }),
          SizedBox(height: 16.h),
          _buildFooterLink('CHÍNH SÁCH BẢO MẬT', () {
            showDialog(
              context: context,
              builder: (_) => const AutoScrollDialog(
                title: 'Bảo mật',
                content: 'CHÍNH SÁCH BẢO MẬT DỮ LIỆU\n\n'
                    'Bảo vệ quyền riêng tư của bạn là ưu tiên hàng đầu tại VocabuRex. Chúng tôi thiết kế hệ thống với tiêu chuẩn bảo mật khắt khe nhất.\n\n'
                    '1. THU THẬP THÔNG TIN\n'
                    'Chúng tôi thu thập email, tên hiển thị, tiến độ học tập, và các phân tích thống kê (như câu hay làm sai) để thiết kế lộ trình học phù hợp nhất cho riêng bạn. Mật khẩu của bạn được băm (hash) mã hóa một chiều.\n\n'
                    '2. CHIA SẺ DỮ LIỆU\n'
                    'Tuyệt đối KHÔNG bán dữ liệu cá nhân cho bên thứ ba. Thông tin của bạn chỉ được lưu trữ nội bộ và sử dụng để hiển thị trên Bảng xếp hạng (Leaderboard) theo sự cho phép của bạn.\n\n'
                    '3. AN TOÀN HỆ THỐNG\n'
                    'Hệ thống máy chủ sử dụng các giao thức mã hóa (HTTPS/WSS) để bảo vệ dữ liệu truyền tải. Chúng tôi liên tục rà soát các lỗ hổng bảo mật để đảm bảo không có bên thứ ba nào can thiệp được vào quá trình học của bạn.\n\n'
                    '4. QUYỀN XÓA DỮ LIỆU\n'
                    'Bạn có toàn quyền làm chủ dữ liệu của mình. Bằng cách sử dụng tính năng "Xóa tài khoản" trong Cài đặt, toàn bộ dữ liệu, lịch sử học tập và điểm số của bạn sẽ bị xóa vĩnh viễn khỏi máy chủ của chúng tôi không thể khôi phục.\n\n'
                    'Mọi thắc mắc về chính sách, vui lòng liên hệ đội ngũ hỗ trợ VocabuRex.',
              ),
            );
          }),
          SizedBox(height: 16.h),
          _buildFooterLink('LỜI CẢM ƠN', () {
            showDialog(
              context: context,
              builder: (_) => const AutoScrollDialog(
                title: 'Lời cảm ơn',
                content: 'LỜI CẢM ƠN TỪ NHÓM PHÁT TRIỂN\n\n\n'
                    'DỰ ÁN KHÓA LUẬN TỐT NGHIỆP\n\n\n\n'
                    'GIẢNG VIÊN HƯỚNG DẪN\n'
                    'Người thầy/cô đã tận tâm định hướng\n'
                    'và chỉ bảo chúng em từng bước một.\n\n\n\n'
                    'ĐỘI NGŨ PHÁT TRIỂN\n'
                    'Những sinh viên nhiệt huyết\n'
                    'đã thức trắng vô số đêm\n'
                    'để gõ từng dòng code, sửa từng lỗi bug.\n\n\n\n'
                    'THIẾT KẾ ĐỒ HỌA (UI/UX)\n'
                    'Những con người tạo ra trải nghiệm mượt mà\n'
                    'với triết lý "Make no mistake, make it simple".\n\n\n\n'
                    'NGƯỜI DÙNG THỬ NGHIỆM\n'
                    'Cảm ơn các bạn đã kiên nhẫn với\n'
                    'những phiên bản đầu tiên đầy lỗi,\n'
                    'và góp ý nhiệt tình để ứng dụng hoàn thiện.\n\n\n\n'
                    'GIA ĐÌNH & BẠN BÈ\n'
                    'Hậu phương vững chắc luôn ở bên\n'
                    'ủng hộ và động viên nhóm trong những lúc khó khăn nhất.\n\n\n\n'
                    'VÀ CUỐI CÙNG...\n'
                    'CẢM ƠN BẠN,\n'
                    'người đang đọc những dòng chữ này,\n'
                    'vì đã lựa chọn VocabuRex làm người bạn đồng hành\n'
                    'trên con đường chinh phục tiếng Anh.\n\n\n\n'
                    'Chặng đường phía trước còn dài,\n'
                    'nhưng chúng ta sẽ cùng nhau tiến bước.\n\n\n\n'
                    'VocabuRex - Vươn tới tầm cao mới.',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.macaw,
            letterSpacing: 0.5,
          ),
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
      backgroundColor: AppColors.snow,
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
                    color: AppColors.bodyText,
                  ),
                ),
              ),
              ListTile(
                title: Text('Thư giãn (5 phút/ngày)', style: TextStyle(color: AppColors.bodyText)),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 5),
              ),
              ListTile(
                title: Text('Bình thường (10 phút/ngày)', style: TextStyle(color: AppColors.bodyText)),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 10),
              ),
              ListTile(
                title: Text('Nghiêm túc (15 phút/ngày)', style: TextStyle(color: AppColors.bodyText)),
                onTap: () => _updatePreferences(context, dailyGoalMinutes: 15),
              ),
              ListTile(
                title: Text('Rất chăm chỉ (30 phút/ngày)', style: TextStyle(color: AppColors.bodyText)),
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
      backgroundColor: AppColors.snow,
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
                    color: AppColors.bodyText,
                  ),
                ),
              ),
              ListTile(
                title: Text('Người mới bắt đầu (Beginner)', style: TextStyle(color: AppColors.bodyText)),
                onTap: () =>
                    _updatePreferences(context, proficiencyLevel: 'BEGINNER'),
              ),
              ListTile(
                title: Text('Sơ cấp (Elementary)', style: TextStyle(color: AppColors.bodyText)),
                onTap: () =>
                    _updatePreferences(context, proficiencyLevel: 'ELEMENTARY'),
              ),
              ListTile(
                title: Text('Trung cấp (Intermediate)', style: TextStyle(color: AppColors.bodyText)),
                onTap: () => _updatePreferences(
                  context,
                  proficiencyLevel: 'INTERMEDIATE',
                ),
              ),
              ListTile(
                title: Text('Cao cấp (Advanced)', style: TextStyle(color: AppColors.bodyText)),
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
