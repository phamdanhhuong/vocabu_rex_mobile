import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/friend/data/services/friend_service.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';

/// A bottom sheet that shows the user's following list for quest invite selection.
/// Calls [onConfirm] with the selected friend's userId.
class FriendPickerSheet extends StatefulWidget {
  final Function(String friendId) onConfirm;
  final List<String> alreadyJoinedIds;
  final List<String> invitedIds;

  const FriendPickerSheet({
    super.key,
    required this.onConfirm,
    this.alreadyJoinedIds = const [],
    this.invitedIds = const [],
  });

  @override
  State<FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends State<FriendPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _allFriends = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowing() async {
    try {
      final result = await _friendService.getFollowingUsers(limit: 100);
      if (mounted) {
        setState(() {
          _allFriends = result;
          _filtered = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _allFriends.where((f) {
        final name = (f['displayName'] ?? f['fullName'] ?? f['username'] ?? '')
            .toString()
            .toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.snow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.swan,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Mời bạn bè',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(height: 12.h),
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên...',
                    prefixIcon: Icon(Icons.search, color: AppColors.eel),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Friend list
              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.eel),
                      )
                    : _error != null
                    ? Center(
                        child: Text(
                          'Không thể tải danh sách bạn bè',
                          style: TextStyle(
                            color: AppColors.cardinal,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy bạn bè',
                          style: TextStyle(
                            color: AppColors.eel,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final friend = _filtered[i];
                          final friendId = friend['id'] as String? ?? '';
                          final name =
                              friend['displayName'] ??
                              friend['fullName'] ??
                              friend['username'] ??
                              'Unknown';
                          final avatar = friend['profilePictureUrl'] as String?;
                          final alreadyJoined = widget.alreadyJoinedIds
                              .contains(friendId);
                          final alreadyInvited = widget.invitedIds
                              .contains(friendId);

                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/publicProfile',
                                arguments: friendId,
                              );
                            },
                            leading: AvatarDisplay(
                              avatarString: avatar,
                              radius: 24,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyText,
                              ),
                            ),
                            subtitle: alreadyJoined
                                ? Text(
                                    'Đã tham gia',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.macaw,
                                    ),
                                  )
                                : alreadyInvited
                                    ? Text(
                                        'Đã mời',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.eel,
                                        ),
                                      )
                                    : null,
                            trailing: alreadyJoined || alreadyInvited
                                ? Icon(
                                    alreadyJoined ? Icons.check_circle : Icons.schedule,
                                    color: alreadyJoined ? AppColors.macaw : AppColors.eel,
                                    size: 24.r,
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onConfirm(friendId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.macaw,
                                      foregroundColor: AppColors.snow,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 10.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'MỜI',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
