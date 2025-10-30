# Friend Search & Follow Feature - Implementation Summary

## 📱 Flutter Mobile App

### Cấu trúc thư mục (Clean Architecture)
```
friend/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart                    # Entity cho User trong friend context
│   ├── repositories/
│   │   └── friend_repository.dart              # Repository interface
│   └── usecases/
│       ├── search_users_usecase.dart           # Use case tìm kiếm user
│       ├── get_suggested_friends_usecase.dart  # Use case lấy gợi ý bạn bè
│       ├── follow_user_usecase.dart            # Use case theo dõi user
│       └── unfollow_user_usecase.dart          # Use case hủy theo dõi
├── data/
│   ├── models/
│   │   └── user_model.dart                     # Model để parse JSON
│   ├── datasources/
│   │   ├── friend_datasource.dart              # DataSource interface
│   │   └── friend_datasource_impl.dart         # DataSource implementation
│   ├── repositories/
│   │   └── friend_repository_impl.dart         # Repository implementation
│   └── services/
│       └── friend_service.dart                 # Service gọi API (Singleton)
└── ui/
    ├── blocs/
    │   └── friend_bloc.dart                    # BLoC quản lý state
    └── widgets/
        ├── find_friends_view.dart              # Màn hình tìm bạn bè chính
        └── search_friends_by_name_view.dart    # Màn hình tìm kiếm theo tên
```

### BLoC Pattern

**Events:**
- `SearchUsersEvent(String query)` - Tìm kiếm user theo query
- `GetSuggestedFriendsEvent()` - Lấy gợi ý bạn bè
- `FollowUserEvent(String userId)` - Theo dõi user
- `UnfollowUserEvent(String userId)` - Hủy theo dõi user
- `ClearSearchEvent()` - Xóa kết quả tìm kiếm

**States:**
- `FriendInit` - Trạng thái ban đầu
- `FriendLoading` - Đang load dữ liệu
- `SuggestedFriendsLoaded(List<UserEntity>)` - Đã load gợi ý
- `SearchResultsLoaded(List<UserEntity>, String query)` - Đã load kết quả tìm kiếm
- `FriendError(String message)` - Lỗi
- `FollowActionInProgress` - Đang thực hiện follow/unfollow
- `FollowActionSuccess(String userId, bool isFollowing)` - Follow/unfollow thành công
- `FollowActionError(String message)` - Lỗi khi follow/unfollow

### API Endpoints (trong api_constants.dart)
```dart
static const String searchUsers = '$apiVersion/social/search';
static const String suggestedFriends = '$apiVersion/social/suggestions';
static String followUser(String userId) => '$apiVersion/social/follow/$userId';
static String unfollowUser(String userId) => '$apiVersion/social/follow/$userId';
```

## 🔧 Backend (NestJS + Prisma)

### API Endpoints

#### 1. **GET** `/social/search?query=...`
Tìm kiếm users theo tên hoặc username

**Headers:**
- `x-user-id`: ID của user hiện tại

**Query Parameters:**
- `query`: Chuỗi tìm kiếm (tối thiểu 2 ký tự)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "user-id",
      "username": "hieu123",
      "displayName": "Võ Trọng Hiếu",
      "avatarUrl": "https://...",
      "isFollowing": false
    }
  ],
  "message": "Search completed successfully"
}
```

#### 2. **GET** `/social/suggestions`
Lấy danh sách gợi ý bạn bè

**Headers:**
- `x-user-id`: ID của user hiện tại

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "user-id",
      "username": "kate123",
      "displayName": "Kate",
      "avatarUrl": "https://...",
      "isFollowing": false,
      "subtext": "Các bạn có thể quen nhau"
    }
  ],
  "message": "Suggestions retrieved successfully"
}
```

#### 3. **POST** `/social/follow/:userId`
Theo dõi một user

**Headers:**
- `x-user-id`: ID của user hiện tại

**Response:**
```json
{
  "success": true,
  "message": "Successfully followed user"
}
```

#### 4. **DELETE** `/social/follow/:userId`
Hủy theo dõi một user

**Headers:**
- `x-user-id`: ID của user hiện tại

**Response:**
```json
{
  "success": true,
  "message": "Successfully unfollowed user"
}
```

### Use Cases
1. **SearchUsersUseCase** - Tìm kiếm users (loại trừ chính mình, kiểm tra trạng thái following)
2. **GetSuggestedFriendsUseCase** - Lấy gợi ý (loại trừ users đã follow và chính mình)
3. **FollowUserUseCase** - Theo dõi user (kiểm tra không tự follow, không follow lại)
4. **UnfollowUserUseCase** - Hủy theo dõi user

### Repository Methods (PrismaUserRelationshipRepository)
```typescript
async searchUsers(currentUserId: string, query: string): Promise<UserSearchResult[]>
async getSuggestedFriends(currentUserId: string): Promise<SuggestedUser[]>
async follow(followerId: string, followingId: string): Promise<UserRelationship>
async unfollow(followerId: string, followingId: string): Promise<boolean>
async isFollowing(followerId: string, followingId: string): Promise<boolean>
```

## 🎨 UI Components

### FindFriendsView
- Hiển thị các nút action: "Chọn từ danh bạ", "Tìm theo tên", "Chia sẻ đường dẫn"
- Danh sách gợi ý kết bạn (scroll ngang)
- Mỗi suggestion card có: avatar, tên, subtext, nút "THEO DÕI", nút đóng (X)
- Sử dụng BlocBuilder để load và hiển thị suggestions

### SearchFriendsView
- Ô tìm kiếm với debounce
- 2 trạng thái:
  - **Không tìm kiếm**: Hiển thị "Gợi ý kết bạn"
  - **Đang tìm kiếm**: Hiển thị "X kết quả"
- Danh sách kết quả với avatar, tên, username, nút follow
- Auto-load suggestions khi mở màn hình
- Search real-time khi nhập text

## 🔄 Data Flow

1. User nhập text vào search box
2. `SearchUsersEvent(query)` được dispatch
3. FriendBloc gọi `SearchUsersUsecase`
4. UseCase gọi Repository
5. Repository gọi Service (API)
6. API trả về data
7. Service parse JSON thành Model
8. Repository convert Model thành Entity
9. UseCase trả Entity về Bloc
10. Bloc emit `SearchResultsLoaded` state
11. UI rebuild với kết quả mới

## ✅ Features Hoàn Thành

✅ Clean Architecture pattern
✅ BLoC state management
✅ Singleton Service pattern
✅ Repository pattern với interface
✅ Use case pattern
✅ Entity/Model separation
✅ Real-time search
✅ Friend suggestions
✅ Follow/Unfollow functionality
✅ Backend API endpoints
✅ Prisma database queries
✅ Error handling
✅ Loading states
✅ Empty states

## 🚀 Cách Sử Dụng

### Flutter
```dart
// Trong widget, wrap với BlocProvider
BlocProvider(
  create: (context) => FriendBloc(
    searchUsersUsecase: SearchUsersUsecase(
      repository: FriendRepositoryImpl(
        friendDataSource: FriendDataSourceImpl(FriendService()),
      ),
    ),
    // ... other use cases
  ),
  child: FindFriendsView(),
)
```

### Backend
```bash
# Service đã được đăng ký trong SocialModule
# Endpoints tự động available sau khi start server
npm run start:dev
```

## 📝 Notes

- Backend sử dụng `fullName` thay vì `displayName` (theo Prisma schema)
- Search case-insensitive (mode: 'insensitive')
- Giới hạn 50 kết quả search, 20 suggestions
- Tất cả imports đều có đường dẫn tuyệt đối (package:vocabu_rex_mobile/...)
- Follow relationship được lưu trong bảng `UserRelationship`
- Không cho phép tự follow chính mình
- Không cho phép follow lại user đã follow
