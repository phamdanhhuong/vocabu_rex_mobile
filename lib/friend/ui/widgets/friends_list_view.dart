import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/friend/data/services/friend_service.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/public_profile_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Định nghĩa màu sắc (nếu cần) ---
const Color _grayText = Color(0xFF777777);
const Color _blueText = Color(0xFF1CB0F6);
const Color _pageBackground = Color(0xFFFFFFFF);
const Color _cardBorderColor = Color(0xFFE5E5E5);

/// Giao diện màn hình "Bạn bè" (Đang theo dõi / Người theo dõi).
class FriendsListView extends StatefulWidget {
  final int initialTabIndex;

  const FriendsListView({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<FriendsListView> createState() => _FriendsListViewState();
}

class _FriendsListViewState extends State<FriendsListView> {
  late int _selectedTabIndex; // 0 = Đang theo dõi, 1 = Người theo dõi
  final FriendService _service = FriendService();

  List<Map<String, dynamic>> _following = [];
  List<Map<String, dynamic>> _followers = [];
  bool _loadingFollowing = false;
  bool _loadingFollowers = false;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    // Load initial tab content
    if (_selectedTabIndex == 0) {
      _loadFollowing();
    } else {
      _loadFollowers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _grayText, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Bạn bè',
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Tab Bar tùy chỉnh
          _buildTabBar(),

          // 2. Nội dung Tab (danh sách)
          Expanded(
            child: _buildCurrentTabContent(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON (HELPER) ---

  /// Tab bar (Đang theo dõi / Người theo dõi)
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorderColor, width: 2.0)),
      ),
      child: Row(
        children: [
          _buildTabItem('ĐANG THEO DÕI', 0),
          _buildTabItem('NGƯỜI THEO DÕI', 1),
        ],
      ),
    );
  }

  /// Một mục tab
  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            // Load data for tab when selected (if not loaded)
            if (_selectedTabIndex == 0 && _following.isEmpty && !_loadingFollowing) {
              _loadFollowing();
            } else if (_selectedTabIndex == 1 && _followers.isEmpty && !_loadingFollowers) {
              _loadFollowers();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          color: Colors.transparent, // Cho phép GestureDetector
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? _blueText : _grayText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              // Đường gạch chân màu xanh
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3.0,
                width: isSelected ? 60.0 : 0.0, // Chiều rộng của gạch chân
                color: _blueText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiển thị nội dung dựa trên tab đang chọn
  Widget _buildCurrentTabContent() {
    if (_selectedTabIndex == 0) {
      return _buildFollowingTab(); // Tab "Đang theo dõi"
    } else {
      return _buildFollowersTab(); // Tab "Người theo dõi"
    }
  }

  // --- CÁC TAB CON ---

  /// Nội dung cho tab "Đang theo dõi" (có nút Thêm bạn bè)
  Widget _buildFollowingTab() {
    if (_loadingFollowing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_following.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: Center(child: Text('Bạn chưa theo dõi ai')),
          ),
          // Nút "Thêm bạn bè"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: () {
                // TODO: Điều hướng đến trang Tìm bạn bè
              },
              child: const Text(
                'THÊM BẠN BÈ',
                style: TextStyle(
                  color: _blueText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _cardBorderColor,
                  width: 2,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _following.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 2,
                  color: _cardBorderColor,
                  indent: 0,
                  endIndent: 0,
                ),
                itemBuilder: (context, index) {
                  final user = _following[index];
                  final displayName = (user['displayName'] ?? user['username'] ?? 'User') as String;
                  final avatarText = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
                  final userId = user['id'] as String? ?? '';
                  return _FriendRow(
                    userId: userId,
                    name: displayName,
                    level: user['subtext'] ?? '',
                    avatarText: avatarText,
                    avatarColor: Colors.blue,
                  );
                },
              ),
            ),
          ),
        ),
        // Nút "Thêm bạn bè"
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: () {
              // TODO: Điều hướng đến trang Tìm bạn bè
            },
            child: const Text(
              'THÊM BẠN BÈ',
              style: TextStyle(
                color: _blueText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Nội dung cho tab "Người theo dõi"
  Widget _buildFollowersTab() {
    if (_loadingFollowers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_followers.isEmpty) {
      return const Center(child: Text('Chưa có người theo dõi'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _cardBorderColor,
            width: 2,
          ),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _followers.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 2,
            color: _cardBorderColor,
            indent: 0,
            endIndent: 0,
          ),
          itemBuilder: (context, index) {
            final user = _followers[index];
            final displayName = (user['displayName'] ?? user['username'] ?? 'User') as String;
            final avatarText = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
            final userId = user['id'] as String? ?? '';
            return _FriendRow(
              userId: userId,
              name: displayName,
              level: user['subtext'] ?? '',
              avatarText: avatarText,
              avatarColor: Colors.blue,
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadFollowing() async {
    setState(() {
      _loadingFollowing = true;
    });
    try {
      final res = await _service.getFollowingUsers();
      setState(() {
        _following = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh sách đang theo dõi')));
    } finally {
      setState(() {
        _loadingFollowing = false;
      });
    }
  }

  Future<void> _loadFollowers() async {
    setState(() {
      _loadingFollowers = true;
    });
    try {
      final res = await _service.getFollowersUsers();
      setState(() {
        _followers = res;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh sách người theo dõi')));
    } finally {
      setState(() {
        _loadingFollowers = false;
      });
    }
  }
}

/// Hàng thông tin một người bạn
class _FriendRow extends StatelessWidget {
  final String userId;
  final String name;
  final String level;
  final String avatarText;
  final Color avatarColor;

  const _FriendRow({
    Key? key,
    required this.userId,
    required this.name,
    required this.level,
    required this.avatarText,
    required this.avatarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (userId.isEmpty) return;
          
          // Lấy username của người dùng hiện tại từ ProfileBloc
          final profileBloc = context.read<ProfileBloc>();
          final currentUserName = profileBloc.state is ProfileLoaded
              ? (profileBloc.state as ProfileLoaded).profile.username
              : 'You';
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicProfilePage(
                userId: userId,
                userName: currentUserName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
                // Avatar (Placeholder)
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    avatarText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Thông tin
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Placeholder cờ
                        Container(
                          width: 24,
                          height: 16,
                          color: Colors.grey[300],
                          child: const Icon(Icons.flag, size: 14, color: _grayText),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          level,
                          style: const TextStyle(
                            fontSize: 15,
                            color: _grayText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Mũi tên
                const Icon(Icons.chevron_right, color: _grayText, size: 28),
              ],
            ),
          ),
        ),
    );
  }
}
