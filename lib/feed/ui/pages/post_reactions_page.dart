import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/data/models/reaction_detail_model.dart';
import 'package:vocabu_rex_mobile/feed/data/services/feed_service.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionsPage extends StatefulWidget {
  final String postId;
  final List<Map<String, dynamic>> reactionSummary; // [{reactionType: 'congrats', count: 5}]

  const PostReactionsPage({
    Key? key,
    required this.postId,
    required this.reactionSummary,
  }) : super(key: key);

  @override
  State<PostReactionsPage> createState() => _PostReactionsPageState();
}

class _PostReactionsPageState extends State<PostReactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<ReactionDetailModel>> _reactionsByType = {};
  bool _isLoading = true;
  String? _error;
  final FeedService _feedService = FeedService();

  @override
  void initState() {
    super.initState();
    
    // Tạo tabs: All + các reaction types có data
    final tabs = ['all', ...widget.reactionSummary.map((r) => r['reactionType'] as String)];
    _tabController = TabController(length: tabs.length, vsync: this);
    
    _loadReactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Gọi API để lấy chi tiết reactions
      final response = await _feedService.getPostReactions(widget.postId);
      final reactions = response.map((r) => ReactionDetailModel.fromJson(r as Map<String, dynamic>)).toList();
      
      // Nhóm reactions theo type
      final Map<String, List<ReactionDetailModel>> grouped = {};
      for (var reaction in reactions) {
        if (!grouped.containsKey(reaction.reactionType)) {
          grouped[reaction.reactionType] = [];
        }
        grouped[reaction.reactionType]!.add(reaction);
      }

      setState(() {
        _reactionsByType = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ReactionDetailModel> _getReactionsForCurrentTab() {
    final currentIndex = _tabController.index;
    
    if (currentIndex == 0) {
      // Tab "All"
      final allReactions = <ReactionDetailModel>[];
      _reactionsByType.values.forEach((reactions) {
        allReactions.addAll(reactions);
      });
      // Sắp xếp theo thời gian
      allReactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allReactions;
    } else {
      // Tab cụ thể
      final reactionType = widget.reactionSummary[currentIndex - 1]['reactionType'] as String;
      return _reactionsByType[reactionType] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tương tác',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                _buildTab('Tất cả', _getTotalCount()),
                ...widget.reactionSummary.map((r) {
                  final type = ReactionType.fromString(r['reactionType'] as String);
                  final count = r['count'] as int;
                  return _buildTab(type?.emoji ?? '🎉', count);
                }),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text('Đã xảy ra lỗi: $_error'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadReactions,
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReactionsList('all'),
                    ...widget.reactionSummary.map((r) {
                      return _buildReactionsList(r['reactionType'] as String);
                    }),
                  ],
                ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          SizedBox(width: 6.w),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalCount() {
    return widget.reactionSummary.fold<int>(0, (sum, r) => sum + (r['count'] as int));
  }

  Widget _buildReactionsList(String reactionType) {
    final reactions = _getReactionsForCurrentTab();

    if (reactions.isEmpty) {
      return Center(
        child: Text(
          'Chưa có tương tác nào',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: reactions.length,
      itemBuilder: (context, index) {
        final reaction = reactions[index];
        return _buildUserReactionItem(reaction);
      },
    );
  }

  Widget _buildUserReactionItem(ReactionDetailModel reaction) {
    final reactionType = ReactionType.fromString(reaction.reactionType) ?? ReactionType.congrats;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Avatar với reaction emoji overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: reaction.user.profilePictureUrl != null
                    ? NetworkImage(reaction.user.profilePictureUrl!)
                    : null,
                child: reaction.user.profilePictureUrl == null
                    ? Text(
                        reaction.user.displayName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    reactionType.emoji,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(width: 16.w),
          
          // Tên người dùng
          Expanded(
            child: Text(
              reaction.user.displayName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Nút Follow/Following
          _buildFollowButton(reaction.user.id),
        ],
      ),
    );
  }

  Widget _buildFollowButton(String userId) {
    // TODO: Kiểm tra trạng thái follow từ state management
    final isFollowing = false; // Mock data - thay bằng state thực tế
    
    return InkWell(
      onTap: () {
        // TODO: Toggle follow
        print('Toggle follow for user: $userId');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : Color(0xFF1CB0F6),
          borderRadius: BorderRadius.circular(12.r),
          border: isFollowing ? Border.all(color: Colors.grey.shade300, width: 2) : null,
        ),
        child: Icon(
          isFollowing ? Icons.person : Icons.person_add,
          size: 18.sp,
          color: isFollowing ? Colors.grey.shade700 : Colors.white,
        ),
      ),
    );
  }
}
