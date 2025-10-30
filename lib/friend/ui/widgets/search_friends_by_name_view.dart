import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/friend/ui/blocs/friend_bloc.dart';
import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';

// --- Định nghĩa màu sắc (nếu cần) ---
const Color _cardBorderColor = Color(0xFFE5E5E5);
const Color _grayText = Color(0xFF777777);
const Color _blueText = Color(0xFF1CB0F6);
const Color _pageBackground = Color(0xFFFFFFFF);

/// Giao diện màn hình "Tìm bạn" (Trạng thái ban đầu và Tìm kiếm).
class SearchFriendsView extends StatefulWidget {
  const SearchFriendsView({Key? key}) : super(key: key);

  @override
  State<SearchFriendsView> createState() => _SearchFriendsViewState();
}

class _SearchFriendsViewState extends State<SearchFriendsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query.isNotEmpty) {
        context.read<FriendBloc>().add(SearchUsersEvent(query));
      } else {
        context.read<FriendBloc>().add(GetSuggestedFriendsEvent());
      }
      setState(() {
        _isSearching = query.isNotEmpty;
      });
    });
    // Load suggested friends initially
    context.read<FriendBloc>().add(GetSuggestedFriendsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Tìm bạn',
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ô tìm kiếm
          _buildSearchBar(),
          const SizedBox(height: 24),

          // 2. Tiêu đề và Danh sách (dựa trên BlocBuilder)
          Expanded(
            child: BlocBuilder<FriendBloc, FriendState>(
              builder: (context, state) {
                if (state is FriendLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchResultsLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '${state.searchResults.length} kết quả',
                          style: const TextStyle(
                            color: AppColors.bodyText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildResultsList(state.searchResults),
                      ),
                    ],
                  );
                } else if (state is SuggestedFriendsLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Gợi ý kết bạn',
                          style: TextStyle(
                            color: AppColors.bodyText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildSuggestionList(state.suggestions),
                      ),
                    ],
                  );
                } else if (state is FriendError) {
                  return Center(
                    child: Text(
                      'Lỗi: ${state.message}',
                      style: const TextStyle(color: _grayText),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON (HELPER) ---

  /// Ô tìm kiếm
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tên hoặc tên người dùng',
          hintStyle: const TextStyle(color: _grayText, fontSize: 18),
          prefixIcon: const Icon(Icons.search, color: _grayText, size: 28),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close, color: _grayText),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: _cardBorderColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: _cardBorderColor, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: _blueText, width: 2.0),
          ),
        ),
        style: const TextStyle(color: AppColors.bodyText, fontSize: 18),
      ),
    );
  }

  /// Danh sách Gợi ý (trạng thái ban đầu)
  Widget _buildSuggestionList(List<UserEntity> suggestions) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'Không có gợi ý nào',
          style: TextStyle(color: _grayText, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: _cardBorderColor,
      ),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _SuggestionRow(
          user: suggestion,
          onFollow: () {
            context.read<FriendBloc>().add(FollowUserEvent(suggestion.id));
          },
          onDismiss: () {
            // TODO: Implement dismiss suggestion
          },
        );
      },
    );
  }

  /// Danh sách Kết quả (khi đang tìm kiếm)
  Widget _buildResultsList(List<UserEntity> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy kết quả nào',
          style: TextStyle(color: _grayText, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultRow(
          user: result,
          onFollow: () {
            context.read<FriendBloc>().add(FollowUserEvent(result.id));
          },
        );
      },
    );
  }
}

// --- CÁC HÀNG TRONG DANH SÁCH ---

/// Hàng gợi ý (có nút X)
class _SuggestionRow extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onFollow;
  final VoidCallback onDismiss;

  const _SuggestionRow({
    Key? key,
    required this.user,
    required this.onFollow,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Tên và subtext
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bodyText),
                ),
                Text(
                  user.subtext ?? '',
                  style: const TextStyle(fontSize: 15, color: _grayText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Nút Theo dõi
          IconButton(
            icon: Icon(
              user.isFollowing ? Icons.person_remove_alt_1_rounded : Icons.person_add_alt_1_rounded,
              color: _blueText,
              size: 28,
            ),
            onPressed: onFollow,
          ),
          // Nút Đóng
          IconButton(
            icon: const Icon(Icons.close, color: _grayText, size: 28),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

/// Hàng kết quả tìm kiếm (không có nút X)
class _SearchResultRow extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onFollow;

  const _SearchResultRow({
    Key? key,
    required this.user,
    required this.onFollow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Tên và username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bodyText),
                ),
                Text(
                  '@${user.username}',
                  style: const TextStyle(fontSize: 15, color: _grayText),
                ),
              ],
            ),
          ),
          // Nút Theo dõi
          IconButton(
            icon: Icon(
              user.isFollowing ? Icons.person_remove_alt_1_rounded : Icons.person_add_alt_1_rounded,
              color: _blueText,
              size: 28,
            ),
            onPressed: onFollow,
          ),
        ],
      ),
    );
  }
}
