import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/avatar_builder_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';
import 'package:vocabu_rex_mobile/theme/widgets/horizontal_carousel.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;

  String? _avatarUrl;
  String? _gender;
  DateTime? _dateOfBirth;

  String? _nativeLanguage;
  String? _targetLanguage;
  String? _proficiencyLevel;
  double _dailyGoalMinutes = 15;

  bool _isLoading = false;

  final List<String> _genders = ['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'];
  final List<String> _languages = ['Vietnamese', 'English', 'Spanish', 'French', 'Japanese', 'Korean', 'Chinese'];
  final List<String> _proficiencyLevels = ['BEGINNER', 'ELEMENTARY', 'INTERMEDIATE', 'UPPER_INTERMEDIATE', 'ADVANCED', 'PROFICIENT'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();

    // Populate current data
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final p = profileState.profile;
      _nameController.text = p.displayName;
      _usernameController.text = p.username;
      _avatarUrl = p.avatarUrl;
      if (_avatarUrl != null && _avatarUrl!.isEmpty) {
        _avatarUrl = null;
      }
      _gender = p.gender;
      if (p.dateOfBirth != null) {
        _dateOfBirth = DateTime.tryParse(p.dateOfBirth!);
      }
      _nativeLanguage = p.nativeLanguage ?? 'Vietnamese';
      _targetLanguage = p.targetLanguage ?? 'English';
      _proficiencyLevel = p.proficiencyLevel ?? 'BEGINNER';
      _dailyGoalMinutes = (p.dailyGoalMinutes ?? 15).toDouble();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().updateProfile(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        profilePictureUrl: _avatarUrl,
        gender: _gender,
        dateOfBirth: _dateOfBirth?.toIso8601String(),
      );

      await AuthService().updatePreferences(
        dailyGoalMinutes: _dailyGoalMinutes.toInt(),
        proficiencyLevel: _proficiencyLevel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Tải lại thông tin profile
        context.read<ProfileBloc>().add(GetProfileEvent());
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = AppPreferences().isDarkMode;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
                ? ColorScheme.dark(
                    primary: AppColors.macaw,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.macaw, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: AppColors.bodyText, // body text color
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.macaw, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final isDark = AppPreferences().isDarkMode;
        final bgColor = isDark ? AppColors.background : AppColors.snow;
        final cardColor = isDark ? AppColors.polar : Colors.white;
        final textColor = AppColors.bodyText;

        return WebPageWrapper(
          mobileScaffold: StaticSpaceBackground(
            child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Hồ sơ của bạn',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'LƯU',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: 
                            FontWeight.w800,
                            color: AppColors.macaw,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZoomIn(child: _buildAvatarSection()),
                    SizedBox(height: 32.h),
                    
                    FadeInRight(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'THÔNG TIN CƠ BẢN',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.wolf,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildBasicInfoFields(),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    FadeInRight(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'MỤC TIÊU HỌC TẬP',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.wolf,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildDailyGoalsCarousel(constraints.maxWidth),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    FadeInRight(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'CÀI ĐẶT NGÔN NGỮ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.wolf,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildLanguageSettings(),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 60.h),
                  ],
                ),
              ); // closes SingleChildScrollView
            }, // closes builder
            ), // closes LayoutBuilder
            ), // closes Form
          ),
          ), // closes Scaffold
        ); // closes WebPageWrapper
      }, // closes builder
    ); // closes ListenableBuilder
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final newUrl = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AvatarBuilderPage(
                initialUrl: _avatarUrl,
              ),
            ),
          );
          if (newUrl != null && newUrl is String) {
            setState(() {
              _avatarUrl = newUrl;
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.macaw, AppColors.cardinal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.macaw.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPreferences().isDarkMode ? AppColors.background : Colors.white,
                ),
                padding: EdgeInsets.all(4.w),
                child: AvatarDisplay(
                  avatarString: _avatarUrl,
                  radius: 56,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.hare,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoFields() {
    final isDark = AppPreferences().isDarkMode;
    final cardColor = isDark ? AppColors.polar : Colors.white;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.swan, width: 2),
      ),
      child: Column(
        children: [
          _buildTextFieldTile(
            icon: Icons.person_rounded,
            iconColor: Colors.blue,
            label: 'Tên hiển thị',
            controller: _nameController,
            hint: 'Nhập tên hiển thị',
          ),
          Divider(height: 1, thickness: 1, color: AppColors.swan, indent: 56.w),
          _buildTextFieldTile(
            icon: Icons.alternate_email_rounded,
            iconColor: Colors.orange,
            label: 'Tên đăng nhập',
            controller: _usernameController,
            hint: 'Nhập tên đăng nhập',
          ),
          Divider(height: 1, thickness: 1, color: AppColors.swan, indent: 56.w),
          _buildSettingTile(
            icon: Icons.cake_rounded,
            iconColor: Colors.pink,
            title: 'Ngày sinh',
            value: _dateOfBirth != null
                ? "${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}"
                : "Chọn ngày sinh",
            onTap: _pickDate,
          ),
          Divider(height: 1, thickness: 1, color: AppColors.swan, indent: 56.w),
          _buildSettingTile(
            icon: Icons.wc_rounded,
            iconColor: Colors.purple,
            title: 'Giới tính',
            value: _gender ?? 'Chọn giới tính',
            onTap: () => _showGenderBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings() {
    final isDark = AppPreferences().isDarkMode;
    final cardColor = isDark ? AppColors.polar : Colors.white;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.swan, width: 2),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.language_rounded,
            iconColor: Colors.teal,
            title: 'Ngôn ngữ mẹ đẻ',
            value: _nativeLanguage ?? 'Chọn ngôn ngữ',
            onTap: () => _showLanguageBottomSheet(context, isNative: true),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.swan, indent: 56.w),
          _buildSettingTile(
            icon: Icons.translate_rounded,
            iconColor: Colors.indigo,
            title: 'Ngôn ngữ muốn học',
            value: _targetLanguage ?? 'Chọn ngôn ngữ',
            onTap: () => _showLanguageBottomSheet(context, isNative: false),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.swan, indent: 56.w),
          _buildSettingTile(
            icon: Icons.school_rounded,
            iconColor: AppColors.cardinal,
            title: 'Trình độ hiện tại',
            value: _formatProficiency(_proficiencyLevel),
            onTap: () => _showProficiencyBottomSheet(context),
          ),
        ],
      ),
    );
  }

  String _formatProficiency(String? level) {
    if (level == null) return 'Chưa chọn';
    switch (level) {
      case 'BEGINNER': return 'Beginner';
      case 'ELEMENTARY': return 'Elementary';
      case 'INTERMEDIATE': return 'Intermediate';
      case 'UPPER_INTERMEDIATE': return 'Upper Int.';
      case 'ADVANCED': return 'Advanced';
      case 'PROFICIENT': return 'Proficient';
      default: return level;
    }
  }

  Widget _buildDailyGoalsCarousel(double parentWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return SizedBox(
      height: 160.h,
      width: parentWidth,
      child: isWeb
          ? HorizontalCarousel(
              showArrows: false,
              pages: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGoalCard(5, 'Thư giãn', '🐢', Colors.green),
                    SizedBox(width: 16.w),
                    _buildGoalCard(10, 'Bình thường', '🚶', Colors.blue),
                    SizedBox(width: 16.w),
                    _buildGoalCard(15, 'Nghiêm túc', '🏃', Colors.orange),
                    SizedBox(width: 16.w),
                    _buildGoalCard(30, 'Cực cháy', '🚀', AppColors.cardinal),
                  ],
                ),
              ],
            )
          : HorizontalCarousel(
              showArrows: true,
              pages: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGoalCard(5, 'Thư giãn', '🐢', Colors.green),
                    SizedBox(width: 16.w),
                    _buildGoalCard(10, 'Bình thường', '🚶', Colors.blue),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGoalCard(15, 'Nghiêm túc', '🏃', Colors.orange),
                    SizedBox(width: 16.w),
                    _buildGoalCard(30, 'Cực cháy', '🚀', AppColors.cardinal),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildGoalCard(int minutes, String title, String emoji, Color color) {
    final isSelected = _dailyGoalMinutes == minutes.toDouble();
    final isDark = AppPreferences().isDarkMode;
    final cardColor = isDark ? AppColors.polar : Colors.white;
    final textColor = AppColors.bodyText;

    return GestureDetector(
      onTap: () {
        setState(() {
          _dailyGoalMinutes = minutes.toDouble();
        });
      },
      child: Container(
        width: 110.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : AppColors.swan,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 32.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : textColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '$minutes phút',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.wolf,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.wolf,
                  ),
                ),
                TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: AppPreferences().isDarkMode ? Colors.grey[600] : AppColors.hare),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Không được để trống';
                    }
                    if (label == 'Tên đăng nhập' && val.trim().length < 3) {
                      return 'Phải có ít nhất 3 ký tự';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.wolf,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded, color: AppPreferences().isDarkMode ? Colors.grey[400] : AppColors.hare, size: 24.sp),
          ],
        ),
      ),
    );
  }

  void _showGenderBottomSheet(BuildContext context) {
    _showOptionsBottomSheet(
      title: 'Giới tính',
      options: _genders,
      currentValue: _gender,
      onSelected: (val) => setState(() => _gender = val),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, {required bool isNative}) {
    _showOptionsBottomSheet(
      title: isNative ? 'Ngôn ngữ mẹ đẻ' : 'Ngôn ngữ muốn học',
      options: _languages,
      currentValue: isNative ? _nativeLanguage : _targetLanguage,
      onSelected: (val) {
        setState(() {
          if (isNative) {
            _nativeLanguage = val;
          } else {
            _targetLanguage = val;
          }
        });
      },
    );
  }

  void _showProficiencyBottomSheet(BuildContext context) {
    _showOptionsBottomSheet(
      title: 'Trình độ hiện tại',
      options: _proficiencyLevels,
      currentValue: _proficiencyLevel,
      onSelected: (val) => setState(() => _proficiencyLevel = val),
    );
  }

  void _showOptionsBottomSheet({
    required String title,
    required List<String> options,
    required String? currentValue,
    required Function(String) onSelected,
  }) {
    final isDark = AppPreferences().isDarkMode;
    final bgColor = isDark ? AppColors.background : AppColors.snow;
    final textColor = AppColors.bodyText;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.swan,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: options.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.swan),
                  itemBuilder: (context, index) {
                    final item = options[index];
                    final isSelected = item == currentValue;
                    final displayItem = title == 'Trình độ hiện tại' ? _formatProficiency(item) : item;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      tileColor: isSelected ? AppColors.macaw.withValues(alpha: 0.1) : null,
                      title: Text(
                        displayItem,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.macaw : textColor,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: AppColors.macaw, size: 24.sp)
                          : null,
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}
