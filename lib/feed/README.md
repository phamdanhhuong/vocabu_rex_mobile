# Feed UI - Frontend Implementation

Frontend implementation cho Feed System của VocabuRex Mobile App.

## 📁 Cấu trúc

```
feed/
├── data/
│   ├── models/
│   │   └── feed_post_model.dart         # Data models
│   └── services/
│       └── feed_service.dart            # API service
├── ui/
│   ├── pages/
│   │   └── feed_page.dart               # Main feed page
│   ├── widgets/
│   │   └── feed_post_card.dart          # Post card widget
│   └── utils/
│       └── feed_constants.dart          # Constants & enums
```

## 🎨 Features

### Feed Post Card
- **User Avatar & Name**: Hiển thị avatar và tên người đăng
- **User Level Badge**: Badge hiển thị level của user
- **Post Type Icon**: Icon và màu sắc theo loại post
- **Post Content**: Nội dung bài đăng được generate tự động
- **Reactions Summary**: Tổng hợp số lượng reactions
- **Comment Count**: Số lượng comments
- **Action Buttons**: Reaction và Comment buttons
- **Time Ago**: Hiển thị thời gian đăng (vừa xong, 5 phút trước, ...)
- **Delete Option**: Chỉ owner mới thấy nút delete

### Feed Page
- **Pull to Refresh**: Kéo xuống để refresh feed
- **Infinite Scroll**: Tự động load thêm khi scroll đến cuối
- **Reaction Picker**: Bottom sheet chọn reaction (5 loại)
- **Empty State**: Hiển thị UI khi chưa có posts
- **Loading States**: Loading indicators khi đang tải
- **Error Handling**: Xử lý lỗi và hiển thị snackbar

## 🎯 Post Types & Icons

| Post Type | Icon | Color | Background |
|-----------|------|-------|------------|
| STREAK_MILESTONE | 🔥 local_fire_department | #FF5722 | #FFEBEE |
| LEAGUE_PROMOTION | 🏆 military_tech | #FFD700 | #FFF9E6 |
| LEAGUE_TOP_3 | 🏆 emoji_events | #FF9800 | #FFF3E0 |
| NEW_FOLLOWER | 👥 people | #2196F3 | #E3F2FD |
| ACHIEVEMENT_UNLOCKED | ⭐ stars | #9C27B0 | #F3E5F5 |
| LEVEL_UP | ⬆️ trending_up | #4CAF50 | #E8F5E9 |
| QUEST_COMPLETED | ✅ task_alt | #00BCD4 | #E0F7FA |
| PERFECT_SCORE | ⭐ star | #FFEB3B | #FFFDE7 |
| XP_MILESTONE | ✨ auto_awesome | #673AB7 | #EDE7F6 |

## 😊 Reaction Types

| Type | Emoji | Value |
|------|-------|-------|
| Congrats | 🎉 | CONGRATS |
| Fire | 🔥 | FIRE |
| Clap | 👏 | CLAP |
| Heart | ❤️ | HEART |
| Strong | 💪 | STRONG |

## 🔌 API Integration

Service sử dụng `FeedService` để call các endpoints:

```dart
// Get feed
final posts = await FeedService().getFeed(limit: 20, offset: 0);

// Toggle reaction
await FeedService().toggleReaction(postId, 'FIRE');

// Add comment
await FeedService().addComment(postId, 'Great job!');

// Delete post
await FeedService().deletePost(postId);
```

## 📱 Usage

### Thêm vào Navigation

```dart
// Navigate to feed page
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const FeedPage()),
);
```

### Custom Feed (User Profile)

Để hiển thị posts của một user cụ thể:

```dart
Future<List<FeedPostModel>> loadUserPosts(String userId) async {
  return await FeedService().getUserPosts(userId, limit: 20);
}
```

## 🎨 Customization

### Colors

Màu sắc được định nghĩa trong `FeedColors`:

```dart
class FeedColors {
  static const Color background = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;
  static const Color primary = Color(0xFF1CB0F6);
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);
  // ...
}
```

### Post Type Config

Customize icons và colors cho mỗi post type trong `PostTypeConfig.configs`.

## 🔄 State Management

Current implementation sử dụng **StatefulWidget** với local state management:

- `_posts`: Danh sách posts
- `_isLoading`: Loading state
- `_hasMore`: Có còn posts để load không
- `_offset`: Current pagination offset

Có thể refactor sang **BLoC** pattern như các modules khác nếu cần.

## 📋 TODO / Future Enhancements

- [ ] Implement Comments Page (hiện tại chỉ placeholder)
- [ ] Navigate to User Profile khi tap avatar/name
- [ ] Image support trong posts
- [ ] Edit post capability
- [ ] Share post functionality
- [ ] Notifications khi có reactions/comments mới
- [ ] Filter posts by type
- [ ] Search trong feed

## 🐛 Known Issues

- **AuthService getCurrentUser**: Đã chuyển sang dùng `TokenManager.getUserInfo()`
- **timeago package**: Đã implement custom `_formatTimeAgo()` function

## 🧪 Testing

Test các scenarios:

1. **Empty Feed**: Chưa follow ai → Hiển thị empty state
2. **Pull to Refresh**: Kéo xuống → Load lại feed
3. **Infinite Scroll**: Scroll xuống cuối → Tự động load thêm
4. **React to Post**: Tap reaction button → Show picker → Select reaction
5. **Delete Own Post**: Tap delete → Confirm dialog → Post bị xóa
6. **Error Handling**: Mất mạng → Hiển thị error message

## 📦 Dependencies

```yaml
dependencies:
  flutter_screenutil: ^5.9.0  # Responsive UI
  dio: ^5.3.3                 # HTTP client
  shared_preferences: ^2.2.2  # Local storage
```

## 🎯 Integration với Backend

API endpoints đã được thêm vào `api_constants.dart`:

```dart
static const String feed = '/users/feed';
static String userPosts(String userId) => '/users/feed/user/$userId';
static String deletePost(String postId) => '/users/feed/posts/$postId';
static String postReactions(String postId) => '/users/feed/posts/$postId/reactions';
static String postComments(String postId) => '/users/feed/posts/$postId/comments';
static String comment(String commentId) => '/users/feed/comments/$commentId';
```

Backend tự động tạo posts khi user:
- Đạt streak milestone (7, 14, 30, 50, 100, 365 ngày)
- Thăng hạng đấu trường
- Vào top 3 giải đấu
- Đạt mốc followers (mỗi 10 người)
- Mở khóa achievement tier 3+
- Lên level (mỗi 5 levels)
- Hoàn thành special quests
- Đạt XP milestones (1K, 5K, 10K, ...)

Posts tự động được sync vào feed của followers!
