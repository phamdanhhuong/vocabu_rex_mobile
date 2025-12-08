import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_event.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

const Color _questPurple = Color(0xFF7032B3);

class DailyQuestCard extends StatefulWidget {
  final UserQuestEntity userQuest;
  final String? isClaimingId;

  const DailyQuestCard({
    Key? key,
    required this.userQuest,
    this.isClaimingId,
  }) : super(key: key);

  @override
  State<DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends State<DailyQuestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    // Start shaking animation when quest can be claimed
    if (widget.userQuest.isCompleted && !widget.userQuest.isClaimed) {
      _startShaking();
    }
  }

  void _startShaking() {
    _shakeController.repeat(period: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chestType = widget.userQuest.quest.chestType;
    final progress = widget.userQuest.progressPercentage;
    final canClaim = widget.userQuest.isCompleted && !widget.userQuest.isClaimed;
    final isClaiming = widget.isClaimingId == widget.userQuest.questId;
    
    print('[DailyQuestCard] Building ${widget.userQuest.quest.name}:');
    print('  status: ${widget.userQuest.status}');
    print('  isClaimed: ${widget.userQuest.isClaimed}');
    print('  canClaim: $canClaim');
    print('  isClaiming: $isClaiming');
    print('  isClaimingId: ${widget.isClaimingId}');
    print('  questId: ${widget.userQuest.questId}');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest name
          Text(
            widget.userQuest.quest.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Progress bar with chest icon
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(_questPurple),
                        minHeight: 32.h,
                      ),
                    ),
                    // Progress text overlaid on the bar
                    Text(
                      '${widget.userQuest.progress} / ${widget.userQuest.requirement}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: progress > 0.5 ? Colors.white : AppColors.eel,
                        shadows: progress > 0.5 ? [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ] : null,
                      ),
                    ),
                  ],
                ),
              ),
              // Chest icon
              _buildChestIcon(chestType, widget.userQuest.isCompleted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChestIcon(dynamic chestType, bool isCompleted) {
    final canClaim = widget.userQuest.isCompleted && !widget.userQuest.isClaimed;
    final isClaiming = widget.isClaimingId == widget.userQuest.questId;
    
    // Determine chest type
    String chestTypeName = 'bronze'; // default
    
    if (chestType != null) {
      final typeStr = chestType.toString().toLowerCase();
      if (typeStr.contains('bronze')) {
        chestTypeName = 'bronze';
      } else if (typeStr.contains('silver')) {
        chestTypeName = 'silver';
      } else if (typeStr.contains('gold')) {
        chestTypeName = 'gold';
      } else if (typeStr.contains('friend')) {
        chestTypeName = 'friend';
      }
    }
    
    // Determine state:
    // 1. 'close' - not completed yet
    // 2. 'close' with animation - completed but not claimed (canClaim)
    // 3. 'open' - claimed
    String state;
    if (widget.userQuest.isClaimed) {
      state = 'open';
    } else {
      state = 'close';
    }
    
    String imagePath = 'assets/icons/chest_${chestTypeName}_$state.png';
    
    Widget chestImage = Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if image not found
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: widget.userQuest.isClaimed ? Colors.amber[700] : Colors.grey[600],
            size: 28.w,
          ),
        );
      },
    );
    
    // If can claim (completed but not claimed), add shake animation and make it tappable
    if (canClaim) {
      return GestureDetector(
        onTap: isClaiming ? null : () {
          context.read<QuestBloc>().add(ClaimQuestEvent(widget.userQuest.questId));
        },
        child: Container(
          width: 48.w,
          height: 48.w,
          child: isClaiming
              ? Center(
                  child: DotLoadingIndicator(
                    color: _questPurple,
                    size: 8,
                  ),
                )
              : AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _shakeAnimation.value,
                      child: child,
                    );
                  },
                  child: chestImage,
                ),
        ),
      );
    }
    
    // Otherwise, just show static chest (close or open)
    return Container(
      width: 48.w,
      height: 48.w,
      child: chestImage,
    );
  }

}
