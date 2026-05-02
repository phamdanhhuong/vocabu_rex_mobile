import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/quest_action_button.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_event.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_state.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'friend_picker_sheet.dart';

class FriendsQuestCard extends StatefulWidget {
  final UserQuestEntity userQuest;
  final String? isClaimingId;

  const FriendsQuestCard({
    super.key,
    required this.userQuest,
    this.isClaimingId,
  });

  @override
  State<FriendsQuestCard> createState() => _FriendsQuestCardState();
}

class _FriendsQuestCardState extends State<FriendsQuestCard> {
  late FriendsQuestBloc _bloc;
  bool _nudging = false;

  @override
  void initState() {
    super.initState();
    // Create a per-card FriendsQuestBloc instance
    _bloc = sl<FriendsQuestBloc>();
    _initBloc();
  }

  Future<void> _initBloc() async {
    // Get currentUserId and set it on the bloc
    final userInfo = await TokenManager.getUserInfo();
    final userId = userInfo['userId'];
    _bloc.currentUserId = userId;
    // Load participants for this specific quest
    _bloc.add(
      GetFriendsQuestParticipantsEvent(
        questKey: widget.userQuest.quest.key,
        weekStartDate: widget.userQuest.startDate,
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String _formatTimeRemaining() {
    final now = DateTime.now();
    final endDate = widget.userQuest.endDate;
    final diff = endDate.difference(now);

    if (diff.isNegative) return 'Đã hết hạn';

    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      return '${diff.inDays} ngày ${hours}h';
    } else if (diff.inHours > 0) {
      final minutes = diff.inMinutes % 60;
      return '${diff.inHours}h ${minutes}m';
    } else {
      return '${diff.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.userQuest.progressPercentage;

    return BlocProvider.value(
      value: _bloc,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.swan, width: 2),
        ),
        child: Column(
          children: [
            // Participant avatars section (dynamic from data)
            BlocBuilder<FriendsQuestBloc, FriendsQuestState>(
              builder: (context, state) {
                if (state is FriendsQuestParticipantsLoaded) {
                  return _buildAvatarSection(state.participants);
                }
                return _buildAvatarSection([]);
              },
            ),

            SizedBox(height: 16.h),

            // Target progress
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Đạt được ${widget.userQuest.requirement} KN',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bodyText,
                          ),
                        ),
                      ),
                      // Remaining time badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.w,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatTimeRemaining(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.swan,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.eel),
                      minHeight: 20.h,
                    ),
                  ),

                  SizedBox(height: 4.h),
                  // Progress text
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${widget.userQuest.progress} / ${widget.userQuest.requirement}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.eel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Participants info
                  BlocBuilder<FriendsQuestBloc, FriendsQuestState>(
                    builder: (context, state) {
                      if (state is FriendsQuestParticipantsLoaded) {
                        return _buildParticipantsList(state.participants);
                      } else if (state is FriendsQuestLoading) {
                        return Center(
                          child: DotLoadingIndicator(
                            color: AppColors.eel,
                            size: 12.0,
                          ),
                        );
                      } else if (state is FriendsQuestError) {
                        return Text(
                          'Không thể tải danh sách thành viên',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.cardinal,
                          ),
                        );
                      }
                      return _buildParticipantsPlaceholder();
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Action buttons
                  BlocBuilder<FriendsQuestBloc, FriendsQuestState>(
                    builder: (context, state) {
                      final isJoined = state is FriendsQuestParticipantsLoaded
                          ? state.isCurrentUserJoined
                          : false;
                      final participants =
                          state is FriendsQuestParticipantsLoaded
                          ? state.participants
                          : <dynamic>[];
                      final joinedIds = participants
                          .map((p) => p.userId as String)
                          .toList();

                      final isWide =
                          kIsWeb && MediaQuery.of(context).size.width >= 768;

                      if (isWide) {
                        return Row(
                          children: [
                            if (!isJoined) ...[
                              Expanded(
                                child: QuestActionButton(
                                  emoji: '✋',
                                  label: 'THAM GIA',
                                  onPressed: () {
                                    _bloc.add(
                                      JoinFriendsQuestEvent(
                                        questKey: widget.userQuest.quest.key,
                                        weekStartDate:
                                            widget.userQuest.startDate,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                            ],
                            Expanded(
                              child: QuestActionButton(
                                emoji: '👋',
                                label: _nudging ? '...' : 'NHẮC NHẸ',
                                onPressed: _nudging ? null : () => _onNudge(),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: QuestActionButton(
                                emoji: '🎁',
                                label: 'MỜI BẠN',
                                onPressed: () =>
                                    _showInviteFriendDialog(context, joinedIds),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            if (!isJoined) ...[
                              SizedBox(
                                width: double.infinity,
                                child: QuestActionButton(
                                  emoji: '✋',
                                  label: 'THAM GIA',
                                  onPressed: () {
                                    _bloc.add(
                                      JoinFriendsQuestEvent(
                                        questKey: widget.userQuest.quest.key,
                                        weekStartDate:
                                            widget.userQuest.startDate,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: QuestActionButton(
                                    emoji: '👋',
                                    label: _nudging ? '...' : 'NHẮC NHẸ',
                                    onPressed: _nudging
                                        ? null
                                        : () => _onNudge(),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: QuestActionButton(
                                    emoji: '🎁',
                                    label: 'MỜI BẠN',
                                    onPressed: () => _showInviteFriendDialog(
                                      context,
                                      joinedIds,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNudge() async {
    setState(() => _nudging = true);
    try {
      await QuestService().nudgeFriendsQuest(widget.userQuest.quest.key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đăng nhắc nhẹ lên bảng tin!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể nhắc nhẹ: $e'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _nudging = false);
    }
  }

  Widget _buildAvatarSection(List participants) {
    // Show up to 3 participant avatars, or placeholders
    final displayList = participants.take(3).toList();

    return SizedBox(
      height: 80.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (displayList.isEmpty) ...[
            // Placeholder silhouettes when no participants
            Positioned(
              left: 60.w,
              child: _buildAvatarCircle(null, null, AppColors.swan),
            ),
            Positioned(
              child: _buildAvatarCircle(
                null,
                null,
                AppColors.eel,
                isCenter: true,
              ),
            ),
            Positioned(
              right: 60.w,
              child: _buildAvatarCircle(null, null, AppColors.swan),
            ),
          ] else ...[
            // Dynamic avatars from actual participants
            for (int i = 0; i < displayList.length; i++)
              Positioned(
                left: i == 0 && displayList.length > 1 ? 60.w : null,
                right: i == 2 || (i == 1 && displayList.length == 2)
                    ? 60.w
                    : null,
                child: _buildAvatarCircle(
                  displayList[i].user?.displayName,
                  displayList[i].user?.profilePictureUrl,
                  i == 0
                      ? AppColors.eel
                      : (i == 1 ? const Color(0xFF58CC02) : AppColors.swan),
                  isCenter:
                      displayList.length == 1 ||
                      (displayList.length == 3 && i == 1),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(
    String? displayName,
    String? avatarUrl,
    Color fallbackColor, {
    bool isCenter = false,
  }) {
    final size = isCenter ? 72.w : 56.w;
    final fontSize = isCenter ? 22.sp : 16.sp;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCenter ? const Color(0xFF58CC02) : AppColors.swan,
          width: isCenter ? 3 : 2,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildFallbackAvatar(displayName, fallbackColor, fontSize),
              )
            : _buildFallbackAvatar(displayName, fallbackColor, fontSize),
      ),
    );
  }

  Widget _buildFallbackAvatar(
    String? displayName,
    Color color,
    double fontSize,
  ) {
    return Container(
      color: color.withOpacity(0.3),
      child: Center(
        child: displayName != null && displayName.isNotEmpty
            ? Text(
                displayName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
            : Icon(Icons.person, color: color, size: fontSize * 1.5),
      ),
    );
  }

  Widget _buildParticipantsPlaceholder() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.group, size: 16.w, color: AppColors.eel),
          SizedBox(width: 8.w),
          Text(
            'Đang tải danh sách thành viên...',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.eel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(List participants) {
    if (participants.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.group, size: 16.w, color: AppColors.eel),
            SizedBox(width: 8.w),
            Text(
              'Chưa có thành viên nào',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.eel,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, size: 16.w, color: AppColors.eel),
              SizedBox(width: 8.w),
              Text(
                'Thành viên (${participants.length})',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.eel,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...participants
              .take(3)
              .map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12.w,
                        backgroundColor: AppColors.eel,
                        backgroundImage:
                            (p.user?.profilePictureUrl != null &&
                                (p.user?.profilePictureUrl as String)
                                    .isNotEmpty)
                            ? NetworkImage(p.user!.profilePictureUrl!)
                            : null,
                        child:
                            (p.user?.profilePictureUrl == null ||
                                (p.user?.profilePictureUrl as String).isEmpty)
                            ? Text(
                                (p.user?.displayName ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.snow,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          p.user?.displayName ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.bodyText,
                          ),
                        ),
                      ),
                      Text(
                        '${p.contribution} KN',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.eel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _showInviteFriendDialog(BuildContext context, List<String> joinedIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FriendPickerSheet(
        alreadyJoinedIds: joinedIds,
        onConfirm: (friendId) {
          _bloc.add(
            InviteFriendToQuestEvent(
              questKey: widget.userQuest.quest.key,
              friendId: friendId,
              weekStartDate: widget.userQuest.startDate,
            ),
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Đã gửi lời mời!')));
        },
      ),
    );
  }
}
