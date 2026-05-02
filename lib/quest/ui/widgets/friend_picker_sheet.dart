import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/friend/data/services/friend_service.dart';

/// A bottom sheet that shows the user's following list for quest invite selection.
/// Calls [onConfirm] with the selected friend's userId.
class FriendPickerSheet extends StatefulWidget {
  final Function(String friendId) onConfirm;
  final List<String> alreadyJoinedIds;

  const FriendPickerSheet({
    super.key,
    required this.onConfirm,
    this.alreadyJoinedIds = const [],
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
        final name = (f['fullName'] ?? f['username'] ?? '')
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
                              friend['fullName'] ??
                              friend['username'] ??
                              'Unknown';
                          final avatar = friend['profilePictureUrl'] as String?;
                          final alreadyJoined = widget.alreadyJoinedIds
                              .contains(friendId);

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.eel,
                              backgroundImage:
                                  (avatar != null && avatar.isNotEmpty)
                                  ? NetworkImage(avatar)
                                  : null,
                              child: (avatar == null || avatar.isEmpty)
                                  ? Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: AppColors.snow,
                                        fontSize: 14.sp,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: alreadyJoined
                                ? Text(
                                    'Đã tham gia',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.eel,
                                    ),
                                  )
                                : null,
                            trailing: alreadyJoined
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.bee,
                                    size: 20.r,
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      widget.onConfirm(friendId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.bee,
                                      foregroundColor: AppColors.snow,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Mời',
                                      style: TextStyle(fontSize: 13.sp),
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
