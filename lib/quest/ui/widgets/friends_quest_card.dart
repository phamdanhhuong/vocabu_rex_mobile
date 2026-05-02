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
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import 'friend_picker_sheet.dart';

class FriendsQuestCard extends StatefulWidget {
  final UserQuestEntity userQuest;
  final String? isClaimingId;

  const FriendsQuestCard({
    Key? key,
    required this.userQuest,
    this.isClaimingId,
  }) : super(key: key);

  @override
  State<FriendsQuestCard> createState() => _FriendsQuestCardState();
}

class _FriendsQuestCardState extends State<FriendsQuestCard> {
  @override
  void initState() {
    super.initState();
    // Load participants when card is displayed
    _loadParticipants();
  }

  void _loadParticipants() {
    context.read<FriendsQuestBloc>().add(
          GetFriendsQuestParticipantsEvent(
            questKey: widget.userQuest.quest.key,
            weekStartDate: widget.userQuest.startDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.userQuest.progressPercentage;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.swan,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Three avatars section
          SizedBox(
            height: 100.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left silhouette
                Positioned(
                  left: 40.w,
                  child: _buildSilhouette(AppColors.swan),
                ),
                // Center egg (green mascot)
                Positioned(
                  child: _buildCenterEgg(),
                ),
                // Right silhouette
                Positioned(
                  right: 40.w,
                  child: _buildSilhouette(AppColors.eel),
                ),
              ],
            ),
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
                Text(
                  'Đạt được ${widget.userQuest.requirement} KN',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bodyText,
                  ),
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
                
                SizedBox(height: 16.h),
                
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
                    final participants = state is FriendsQuestParticipantsLoaded
                        ? state.participants
                        : <dynamic>[];
                    final joinedIds = participants.map((p) => p.userId as String).toList();

                    final isWide = kIsWeb && MediaQuery.of(context).size.width >= 768;

                    if (isWide) {
                      return Row(
                        children: [
                          if (!isJoined) ...
                            [
                              Expanded(
                                child: QuestActionButton(
                                  emoji: '✋',
                                  label: 'THAM GIA',
                                  onPressed: () {
                                    context.read<FriendsQuestBloc>().add(
                                      JoinFriendsQuestEvent(
                                        questKey: widget.userQuest.quest.key,
                                        weekStartDate: widget.userQuest.startDate,
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
                              label: 'NHẮC NHẸ',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã nhắc nhẹ bạn bè!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: QuestActionButton(
                              emoji: '🎁',
                              label: 'MỜI BẠN',
                              onPressed: () => _showInviteFriendDialog(context, joinedIds),
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
                                  context.read<FriendsQuestBloc>().add(
                                    JoinFriendsQuestEvent(
                                      questKey: widget.userQuest.quest.key,
                                      weekStartDate: widget.userQuest.startDate,
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
                                  label: 'NHẮC NHẸ',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã nhắc nhẹ bạn bè!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: QuestActionButton(
                                  emoji: '🎁',
                                  label: 'MỜI BẠN',
                                  onPressed: () => _showInviteFriendDialog(context, joinedIds),
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
          ...participants.take(3).map((p) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12.w,
                      backgroundColor: AppColors.eel,
                      child: Text(
                        (p.user?.displayName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.snow,
                        ),
                      ),
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
              )),
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
          context.read<FriendsQuestBloc>().add(
            InviteFriendToQuestEvent(
              questKey: widget.userQuest.quest.key,
              friendId: friendId,
              weekStartDate: widget.userQuest.startDate,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã gửi lời mời!')),
          );
        },
      ),
    );
  }

  Widget _buildSilhouette(Color color) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: color,
        size: 40.w,
      ),
    );
  }

  Widget _buildCenterEgg() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(40.w),
        border: Border.all(color: AppColors.bee, width: 3),
      ),
      child: Center(
        child: Icon(
          Icons.face,
          color: AppColors.snow,
          size: 50.w,
        ),
      ),
    );
  }
}
