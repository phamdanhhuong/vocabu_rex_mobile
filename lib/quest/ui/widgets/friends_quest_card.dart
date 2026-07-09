import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/quest_action_button.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_event.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_state.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_event.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';
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
      child: FadeIn(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
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

                  // Dual Progress bar
                  BlocBuilder<FriendsQuestBloc, FriendsQuestState>(
                    builder: (context, state) {
                      final participants = state is FriendsQuestParticipantsLoaded ? state.participants : [];
                      
                      double myContrib = 0;
                      double friendsContrib = 0;
                      double req = widget.userQuest.requirement.toDouble();
                      if (req == 0) req = 1;

                      if (participants.isNotEmpty) {
                        for (var p in participants) {
                          if (p.status == 'ACCEPTED') {
                            if (p.userId == _bloc.currentUserId) {
                              myContrib += (p.contribution ?? 0);
                            } else {
                              friendsContrib += (p.contribution ?? 0);
                            }
                          }
                        }
                      } else {
                        // Fallback to widget.userQuest progress if no participant data
                        myContrib = widget.userQuest.progress.toDouble();
                      }

                      final myProgress = (myContrib / req).clamp(0.0, 1.0);
                      final friendsProgress = (friendsContrib / req).clamp(0.0, 1.0);
                      final isFull = (myProgress + friendsProgress) >= 1.0;

                      return Column(
                        children: [
                          Container(
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: AppColors.swan,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // Left side (Me)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: myProgress),
                                  duration: const Duration(seconds: 1),
                                  builder: (context, value, child) {
                                    return FractionallySizedBox(
                                      widthFactor: value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF58CC02),
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(12),
                                            bottomLeft: const Radius.circular(12),
                                            topRight: isFull ? const Radius.circular(12) : Radius.zero,
                                            bottomRight: isFull ? const Radius.circular(12) : Radius.zero,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Right side (Friends)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: friendsProgress),
                                    duration: const Duration(seconds: 1),
                                    builder: (context, value, child) {
                                      return FractionallySizedBox(
                                        widthFactor: value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.macaw,
                                            borderRadius: BorderRadius.only(
                                              topRight: const Radius.circular(12),
                                              bottomRight: const Radius.circular(12),
                                              topLeft: isFull ? const Radius.circular(12) : Radius.zero,
                                              bottomLeft: isFull ? const Radius.circular(12) : Radius.zero,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Center icon / flash
                                if (isFull)
                                  Center(
                                    child: Pulse(
                                      infinite: true,
                                      child: Icon(Icons.flash_on, color: Colors.amber, size: 28.w),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          // Text progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bạn: ${myContrib.toInt()}', style: TextStyle(color: const Color(0xFF58CC02), fontWeight: FontWeight.bold, fontSize: 13.sp)),
                              Text('${(myContrib + friendsContrib).toInt()}/${req.toInt()}', style: TextStyle(color: AppColors.eel, fontWeight: FontWeight.w900, fontSize: 13.sp)),
                              Text('Bạn bè: ${friendsContrib.toInt()}', style: TextStyle(color: AppColors.macaw, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                            ],
                          ),
                        ],
                      );
                    },
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
                      final isInvited = state is FriendsQuestParticipantsLoaded
                          ? state.isCurrentUserInvited
                          : false;
                      final joinedIds = participants
                          .where((p) => p.status == 'ACCEPTED')
                          .map((p) => p.userId as String)
                          .toList();

                      final isWide =
                          kIsWeb && MediaQuery.of(context).size.width >= 768;

                      if (widget.userQuest.isCompleted) {
                        final isClaiming =
                            widget.isClaimingId == widget.userQuest.questId;
                        if (widget.userQuest.isClaimed) {
                          return SizedBox(
                            width: double.infinity,
                            child: QuestActionButton(
                              emoji: '✅',
                              label: 'ĐÃ NHẬN',
                              isDisabled: true,
                              onPressed: null,
                            ),
                          );
                        } else {
                          return SizedBox(
                            width: double.infinity,
                            child: QuestActionButton(
                              emoji: isClaiming ? '⏳' : '🎁',
                              label: isClaiming
                                  ? 'ĐANG NHẬN...'
                                  : 'NHẬN THƯỞNG',
                              isDisabled: isClaiming,
                              onPressed: isClaiming
                                  ? null
                                  : () {
                                      context.read<QuestBloc>().add(
                                        ClaimQuestEvent(
                                          widget.userQuest.questId,
                                        ),
                                      );
                                    },
                            ),
                          );
                        }
                      }

                      if (isWide) {
                        return Row(
                          children: [
                            if (isInvited) ...[
                              Expanded(
                                child: QuestActionButton(
                                  emoji: state is FriendsQuestAccepting
                                      ? '⏳'
                                      : '✅',
                                  label: state is FriendsQuestAccepting
                                      ? 'ĐANG NHẬN...'
                                      : 'CHẤP NHẬN',
                                  onPressed: state is FriendsQuestAccepting
                                      ? null
                                      : () {
                                          _bloc.add(
                                            AcceptFriendsQuestInviteEvent(
                                              questKey:
                                                  widget.userQuest.quest.key,
                                              weekStartDate:
                                                  widget.userQuest.startDate,
                                            ),
                                          );
                                        },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: QuestActionButton(
                                  emoji: state is FriendsQuestRejecting
                                      ? '⏳'
                                      : '❌',
                                  label: state is FriendsQuestRejecting
                                      ? 'ĐANG TỪ CHỐI...'
                                      : 'TỪ CHỐI',
                                  onPressed: state is FriendsQuestRejecting
                                      ? null
                                      : () {
                                          _bloc.add(
                                            RejectFriendsQuestInviteEvent(
                                              questKey:
                                                  widget.userQuest.quest.key,
                                              weekStartDate:
                                                  widget.userQuest.startDate,
                                            ),
                                          );
                                        },
                                ),
                              ),
                              SizedBox(width: 12.w),
                            ] else if (!isJoined) ...[
                              Expanded(
                                child: QuestActionButton(
                                  emoji: state is FriendsQuestJoining
                                      ? '⏳'
                                      : '✋',
                                  label: state is FriendsQuestJoining
                                      ? 'ĐANG VÀO...'
                                      : 'THAM GIA',
                                  onPressed: state is FriendsQuestJoining
                                      ? null
                                      : () {
                                          _bloc.add(
                                            JoinFriendsQuestEvent(
                                              questKey:
                                                  widget.userQuest.quest.key,
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
                                onPressed: () => _showInviteFriendDialog(
                                  context,
                                  joinedIds,
                                  participants
                                      .where((p) => p.status == 'PENDING')
                                      .map((p) => p.userId as String)
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            if (isInvited) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: QuestActionButton(
                                      emoji: state is FriendsQuestAccepting
                                          ? '⏳'
                                          : '✅',
                                      label: state is FriendsQuestAccepting
                                          ? 'ĐANG NHẬN...'
                                          : 'CHẤP NHẬN',
                                      onPressed: state is FriendsQuestAccepting
                                          ? null
                                          : () {
                                              _bloc.add(
                                                AcceptFriendsQuestInviteEvent(
                                                  questKey: widget
                                                      .userQuest
                                                      .quest
                                                      .key,
                                                  weekStartDate: widget
                                                      .userQuest
                                                      .startDate,
                                                ),
                                              );
                                            },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: QuestActionButton(
                                      emoji: state is FriendsQuestRejecting
                                          ? '⏳'
                                          : '❌',
                                      label: state is FriendsQuestRejecting
                                          ? 'ĐANG TỪ CHỐI...'
                                          : 'TỪ CHỐI',
                                      onPressed: state is FriendsQuestRejecting
                                          ? null
                                          : () {
                                              _bloc.add(
                                                RejectFriendsQuestInviteEvent(
                                                  questKey: widget
                                                      .userQuest
                                                      .quest
                                                      .key,
                                                  weekStartDate: widget
                                                      .userQuest
                                                      .startDate,
                                                ),
                                              );
                                            },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                            ] else if (!isJoined) ...[
                              SizedBox(
                                width: double.infinity,
                                child: QuestActionButton(
                                  emoji: state is FriendsQuestJoining
                                      ? '⏳'
                                      : '✋',
                                  label: state is FriendsQuestJoining
                                      ? 'ĐANG VÀO...'
                                      : 'THAM GIA',
                                  onPressed: state is FriendsQuestJoining
                                      ? null
                                      : () {
                                          _bloc.add(
                                            JoinFriendsQuestEvent(
                                              questKey:
                                                  widget.userQuest.quest.key,
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
                                      participants
                                          .where((p) => p.status == 'PENDING')
                                          .map((p) => p.userId as String)
                                          .toList(),
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
              child: _buildAvatarCircle(null, null, AppColors.swan, null, null),
            ),
            Positioned(
              child: _buildAvatarCircle(
                null,
                null,
                AppColors.eel,
                null,
                null,
                isCenter: true,
              ),
            ),
            Positioned(
              right: 60.w,
              child: _buildAvatarCircle(null, null, AppColors.swan, null, null),
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
                  displayList[i].user?.equippedFrameId,
                  displayList[i].user?.equippedBackgroundId,
                  isCenter:
                      displayList.length == 1 ||
                      (displayList.length == 3 && i == 1),
                  isPending: displayList[i].status == 'PENDING',
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
    Color fallbackColor,
    String? frameId,
    String? backgroundId, {
    bool isCenter = false,
    bool isPending = false,
  }) {
    final size = isCenter ? 72.w : 56.w;
    final fontSize = isCenter ? 22.sp : 16.sp;

    return Opacity(
      opacity: isPending ? 0.4 : 1.0,
      child: Container(
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
          child: AvatarDisplay(
            avatarString: avatarUrl,
            frameId: frameId,
            backgroundId: backgroundId,
            radius: size / 2,
          ),
        ),
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
                  child: Opacity(
                    opacity: p.status == 'PENDING' ? 0.4 : 1.0,
                    child: Row(
                      children: [
                        AvatarDisplay(
                          avatarString: p.user?.profilePictureUrl as String?,
                          frameId: p.user?.equippedFrameId,
                          backgroundId: p.user?.equippedBackgroundId,
                          radius: 12.w,
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
                          p.status == 'PENDING' ? '⏳' : '${p.contribution} KN',
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
              ),
        ],
      ),
    );
  }

  void _showInviteFriendDialog(
    BuildContext context,
    List<String> joinedIds,
    List<String> invitedIds,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FriendPickerSheet(
        alreadyJoinedIds: joinedIds,
        invitedIds: invitedIds,
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
