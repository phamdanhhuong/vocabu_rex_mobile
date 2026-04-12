class ApiConfig {
  // Hàm này sẽ lấy giá trị từ cái --dart-define lúc build
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000', // Giá trị dự phòng khi chạy F5 ở máy local
  );
}

class ApiEndpoints {
  // Base URLs
  static const String baseUrl = ApiConfig.baseUrl;
  static const String apiVersion = '';

  // Authentication endpoints
  static const String login = '$apiVersion/auth/login';
  static const String googleLogin = '$apiVersion/auth/google/login';
  static const String facebookLogin = '$apiVersion/auth/facebook/login';
  static const String register = '$apiVersion/auth/register/initiate';
  static const String registerComplete = '$apiVersion/auth/register/complete';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh-token';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // User endpoints
  static const String profile = '$apiVersion/users/profile';
  static const String updateProfile = '$apiVersion/users/profile';
  static const String changePassword = '$apiVersion/users/change-password';

  // Public profile endpoints
  static String publicProfile(String userId) =>
      '$apiVersion/users/profile/$userId';
  static String reportUser(String userId) => '$apiVersion/users/$userId/report';
  static String blockUser(String userId) => '$apiVersion/users/$userId/block';

  // Social endpoints
  static String followUser(String userId) =>
      '$apiVersion/social/follow/$userId';
  static String unfollowUser(String userId) =>
      '$apiVersion/social/follow/$userId';

  // Friend endpoints
  static const String searchUsers = '$apiVersion/social/search';
  static const String suggestedFriends = '$apiVersion/social/suggestions';
  static const String followingUsers = '$apiVersion/social/following';
  static const String followersUsers = '$apiVersion/social/followers';

  // Achievement endpoints
  static const String achievements = '$apiVersion/achievements';
  static const String achievementsUnlocked =
      '$apiVersion/achievements?unlocked=true';
  static const String achievementsSummary = '$apiVersion/achievements/summary';

  //Learning
  static const String progress = '$apiVersion/progress/skill';
  static const String skill = '$apiVersion/learning/skills/';
  static const String exercise = '$apiVersion/learning/lessons/';
  static const String exerciseReview = '$apiVersion/learning/exercises/review';
  static const String exerciseTraining =
      '$apiVersion/learning/exercises/training';
  static const String exercisePronun =
      '$apiVersion/learning/pronunciation/lesson/recommended';
  static const String submit = '$apiVersion/progress/submit-lesson';
  static const String submitPronun =
      '$apiVersion/learning/pronunciation/lesson/result';
  static const String speakCheck = '$apiVersion/speech/transcribe';
  static const String learningPart =
      '$apiVersion/learning/skill-parts/with-progress';

  //Gamification
  static const String energyConsume = '$apiVersion/gamification/energy/consume';
  static const String energyRecharge =
      '$apiVersion/gamification/energy/recharge';
  static const String energyStatus = '$apiVersion/gamification/energy';
  static const String energyBuy = '$apiVersion/gamification/energy/buy';

  static const String currencyStatus = '$apiVersion/gamification/currency';

  static const String streakHistory = '$apiVersion/gamification/streak/history';
  static const String streakFreeze = '$apiVersion/gamification/streak/freeze';
  static const String streakCalendar =
      '$apiVersion/gamification/streak/calendar';

  //Quest
  static const String quests = '$apiVersion/quests';
  static const String questsCompleted = '$apiVersion/quests/completed';
  static String claimQuest(String questId) =>
      '$apiVersion/quests/$questId/claim';
  static const String questChests = '$apiVersion/users/quests/chests';
  static String openChest(String chestId) =>
      '$apiVersion/quests/chests/$chestId/open';
  static String getFriendsQuestParticipants(String questKey) =>
      '$apiVersion/quests/friends/$questKey/participants';
  static String joinFriendsQuest(String questKey) =>
      '$apiVersion/quests/friends/$questKey/join';
  static String inviteFriendToQuest(String questKey) =>
      '$apiVersion/quests/friends/$questKey/invite';

  //Leaderboard
  static const String leaderboardJoin = '$apiVersion/leaderboard/join';
  static const String leaderboardStandings =
      '$apiVersion/leaderboard/standings';
  static const String leaderboardTier = '$apiVersion/leaderboard/tier';
  static const String leaderboardHistory = '$apiVersion/leaderboard/history';

  //Feed
  static const String feed = '$apiVersion/users/feed';
  static String userPosts(String userId) =>
      '$apiVersion/users/feed/user/$userId';
  static String deletePost(String postId) =>
      '$apiVersion/users/feed/posts/$postId';
  static String postReactions(String postId) =>
      '$apiVersion/users/feed/posts/$postId/reactions';
  static String postComments(String postId) =>
      '$apiVersion/users/feed/posts/$postId/comments';
  static String comment(String commentId) =>
      '$apiVersion/users/feed/comments/$commentId';

  //Chat
  static const String startChat = '$apiVersion/chat/start';
  static const String chat = '$apiVersion/chat/message';
  static const String getUserConversations =
      '$apiVersion/chat/user/conversations';
  static const String getConversationHistory = '$apiVersion/chat/conversation';
  static const String imgDescription = '$apiVersion/image-description/score';
  static const String translateScore =
      '$apiVersion/exercise-scoring/translate/score';
  static const String writingScore =
      '$apiVersion/exercise-scoring/writing-prompt/score';

  //Pronunciation
  static const String getPronunProgress =
      '$apiVersion/learning/pronunciation/sounds';

  // Voice Call
  static const String voiceWsNamespace = '/voice'; // Socket.IO namespace
  static const String voiceTts = '$apiVersion/voice/tts';
  static const String voiceStatus = '$apiVersion/voice/status';
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';
}

class ApiResponseKeys {
  static const String data = 'data';
  static const String message = 'message';
  static const String success = 'success';
  static const String error = 'error';
  static const String errors = 'errors';
  static const String statusCode = 'status_code';
  static const String pagination = 'pagination';
  static const String meta = 'meta';
}

class HttpStatus {
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}
