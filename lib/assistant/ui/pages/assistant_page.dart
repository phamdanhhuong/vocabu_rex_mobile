import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/chat_bloc.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/voice_call_bloc.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/voice_call_page.dart';
import 'package:vocabu_rex_mobile/assistant/ui/widgets/chat_input.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vocabu_rex_mobile/assistant/ui/widgets/typewriter_text.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isComposing = false;
  String _selectedMode = 'General'; // General, IELTS, TOEIC
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Map UI mode to backend role
  String get _currentRole {
    switch (_selectedMode) {
      case 'IELTS':
        return 'speaking_partner';
      case 'TOEIC':
        return 'grammar_tutor';
      case 'General':
      default:
        return 'vocabulary_expert';
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatBloc>().add(
      SendMessageEvent(message: text, role: _currentRole),
    );
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    // Don't request focus to avoid keyboard popping back up
  }

  @override
  void initState() {
    super.initState();
    context.read<FabCubit>().hide();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -1.0)).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Fetch conversation history so the Welcome Screen can display the latest 3
    Future.microtask(() {
      if (mounted) {
        context.read<ChatBloc>().add(LoadConversationsEvent());
      }
    });

    // Listen to text changes to update isComposing state
    _controller.addListener(() {
      final isCurrentlyComposing = _controller.text.trim().isNotEmpty;
      if (isCurrentlyComposing != _isComposing) {
        setState(() {
          _isComposing = isCurrentlyComposing;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: StaticSpaceBackground(
        child: Scaffold(
          key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded && state.messages.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.eel),
                  onPressed: () {
                    context.read<ChatBloc>().add(ResetChatEvent());
                  },
                );
              }
              return IconButton(
                icon: Icon(Icons.menu, color: AppColors.eel),
                onPressed: () {
                  // Load history when opening drawer
                  context.read<ChatBloc>().add(LoadConversationsEvent());
                  _scaffoldKey.currentState?.openDrawer();
                },
              );
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VocabuRex AI',
                style: TextStyle(
                  color: AppColors.eel,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Đang trò chuyện: ${_selectedMode}',
                style: TextStyle(
                  color: AppColors.macaw,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        drawer: _buildMainDrawer(),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: FloatingActionButton(
            onPressed: () {
              // Get current conversation ID if available
              String? conversationId;
              final chatState = context.read<ChatBloc>().state;
              if (chatState is ChatLoaded) {
                conversationId = chatState.conversationId;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => VoiceCallBloc(),
                    child: VoiceCallPage(conversationId: conversationId),
                  ),
                ),
              );
            },
            backgroundColor: AppColors.macaw,
            elevation: 4,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
        ),
        body: BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                }
              });
            }
          }, // Kết thúc listener, KHÔNG ĐÓNG NGOẶC TRÒN ) Ở ĐÂY
          // Thuộc tính child nằm BÊN TRONG BlocListener
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoading) {
                return _buildLoadingScreen();
              }
              if (state is ChatLoaded && state.messages.isNotEmpty) {
                // Trigger animation when messages appear
                if (_animationController.status == AnimationStatus.dismissed) {
                  Future.microtask(() => _animationController.forward());
                }
                return _buildChatInterface(state);
              }
              if (state is ChatLoaded) {
                // Reset animation when going back to welcome screen
                if (_animationController.status == AnimationStatus.completed) {
                  Future.microtask(() => _animationController.reverse());
                }
                return _buildVocaburexWelcomeScreen();
              }
              return _buildVocaburexWelcomeScreen();
            },
          ),
        ), // Đóng BlocListener
      ), // Đóng Scaffold
    ), // Đóng StaticSpaceBackground
    ); // Đóng FadeIn
  }

  Widget _buildChatInterface(ChatLoaded state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length + (state.isLoadingMessage ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator as last item
              if (state.isLoadingMessage && index == state.messages.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.polar,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.swan, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DotLoadingIndicator(color: AppColors.macaw, size: 10.0),
                        const SizedBox(width: 8),
                        Text(
                          'Thinking...',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.wolf,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final message = state.messages[index];
              final isUser = message.role == "user";
              return FadeInUp(
                key: ValueKey(message.hashCode),
                duration: const Duration(milliseconds: 300),
                child: Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.macaw.withOpacity(0.2),
                          child: Icon(Icons.smart_toy, size: 18, color: AppColors.macaw),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.macaw : AppColors.snow,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isUser ? 20 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.hare.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TypewriterText(
                            text: message.content,
                            animate: !isUser && index == state.messages.length - 1,
                            builder: (context, animatedText) => MarkdownBody(
                              data: animatedText,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 15,
                                  color: isUser ? AppColors.snow : AppColors.eel,
                                  height: 1.4,
                                ),
                                code: TextStyle(
                                  backgroundColor: isUser ? AppColors.macaw.withOpacity(0.8) : AppColors.polar,
                                  fontFamily: 'monospace',
                                  color: isUser ? AppColors.snow : AppColors.eel,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.featherGreen.withOpacity(0.2),
                          child: Icon(Icons.person, size: 18, color: AppColors.featherGreen),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: ChatInputBar(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: _handleSubmitted,
            onChanged: (_) {},
            isComposing: _isComposing,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: AppColors.polar,
        highlightColor: AppColors.swan,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 200,
                height: 60,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 250,
                height: 100,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 150,
                height: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocaburexWelcomeScreen() {
    String userName = 'Hieu';
    final profileState = context.watch<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      userName = profileState.profile.displayName.split(' ').last;
    }

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: child,
              ),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header Greeting
                      Row(
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.macaw.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.auto_awesome, color: AppColors.macaw, size: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FadeInRight(
                              duration: const Duration(milliseconds: 500),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Xin chào, $userName!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.eel,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tôi có thể giúp gì cho bạn hôm nay?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.wolf,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 2. Chế độ trò chuyện (Horizontal List)
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Chọn Chuyên Gia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.eel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: const Duration(milliseconds: 300),
                              child: _buildPersonaCard(
                                title: 'Giao Tiếp',
                                subtitle: 'Luyện phản xạ',
                                icon: Icons.forum_rounded,
                                color: AppColors.macaw,
                                modeValue: 'General',
                              ),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: const Duration(milliseconds: 400),
                              child: _buildPersonaCard(
                                title: 'IELTS',
                                subtitle: 'Chấm điểm Speaking',
                                icon: Icons.school_rounded,
                                color: AppColors.featherGreen,
                                modeValue: 'IELTS',
                              ),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              delay: const Duration(milliseconds: 500),
                              child: _buildPersonaCard(
                                title: 'Ngữ Pháp',
                                subtitle: 'Sửa lỗi chi tiết',
                                icon: Icons.edit_document,
                                color: AppColors.cardinal,
                                modeValue: 'TOEIC',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. Gợi ý chủ đề (Wrap / Chips)
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          'Chủ Đề Gợi Ý',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.eel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FadeInUp(delay: const Duration(milliseconds: 700), child: _buildTopicChip('Du lịch & Khám phá', Icons.flight_takeoff)),
                          FadeInUp(delay: const Duration(milliseconds: 800), child: _buildTopicChip('Phỏng vấn xin việc', Icons.work_outline)),
                          FadeInUp(delay: const Duration(milliseconds: 900), child: _buildTopicChip('Mua sắm', Icons.shopping_bag_outlined)),
                          FadeInUp(delay: const Duration(milliseconds: 1000), child: _buildTopicChip('Giao tiếp công sở', Icons.business_center_outlined)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 4. Lịch sử / Bài học tiếp tục (Vertical List)
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 1100),
                        child: Text(
                          'Tiếp Tục Học',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.eel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildVerticalHistoryList(),
                      
                      const SizedBox(height: 100), // Spacing for ChatInputBar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Chat Input Bar Fixed at Bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.snow.withOpacity(0.0), AppColors.snow],
                stops: const [0.0, 0.2],
              ),
            ),
            child: ChatInputBar(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _handleSubmitted,
              onChanged: (_) {},
              isComposing: _isComposing,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String modeValue,
  }) {
    final isSelected = _selectedMode == modeValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = modeValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.snow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : AppColors.swan,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.3) : AppColors.hare.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.snow.withOpacity(0.2) : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.snow : color,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.snow : AppColors.eel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.snow.withOpacity(0.9) : AppColors.wolf,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label, IconData icon) {
    return ActionChip(
      onPressed: () {
        _controller.text = 'Tôi muốn luyện tập chủ đề: $label';
        _handleSubmitted(_controller.text);
      },
      avatar: Icon(icon, color: AppColors.macaw, size: 18),
      label: Text(label),
      labelStyle: TextStyle(
        color: AppColors.eel,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.snow,
      side: BorderSide(color: AppColors.swan, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      shadowColor: AppColors.hare.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
  }

  Widget _buildVerticalHistoryList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.conversations.isNotEmpty) {
          final recentConversations = state.conversations.take(3).toList();
          return Column(
            children: recentConversations.asMap().entries.map((entry) {
              int idx = entry.key;
              var conversation = entry.value;
              return FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: Duration(milliseconds: 1200 + idx * 100),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      context.read<ChatBloc>().add(
                        LoadConversationHistoryEvent(
                          conversationId: conversation.id,
                        ),
                      );
                    },
                    child: _buildHistoryListItem(
                      title: conversation.title.isNotEmpty
                          ? conversation.title
                          : 'Trò chuyện #${conversation.id.substring(0, 4)}',
                      subtitle: _formatDate(conversation.createdAt),
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppColors.macaw,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        if (state.isLoadingConversations) {
          return Center(
            child: DotLoadingIndicator(
              color: AppColors.macaw,
              size: 16.0,
            ),
          );
        }

        // Default static items if no history or loading
        return Column(
          children: [
            FadeInUp(
              delay: const Duration(milliseconds: 1200),
              child: _buildHistoryListItem(
                title: 'Sửa lỗi phát âm',
                subtitle: 'IELTS Speaking Part 1',
                icon: Icons.mic_rounded,
                color: AppColors.featherGreen,
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 1300),
              child: _buildHistoryListItem(
                title: 'Luyện từ vựng',
                subtitle: 'Chủ đề: Công nghệ',
                icon: Icons.menu_book_rounded,
                color: AppColors.bee,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.swan, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.hare.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.eel,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.wolf,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.hare),
        ],
      ),
    );
  }

  Widget _buildMainDrawer() {
    return Drawer(
      backgroundColor: AppColors.snow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.smart_toy, color: AppColors.macaw, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'VocabuRex AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.eel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ChatBloc>().add(StartEvent());
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    'Cuộc trò chuyện mới',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.macaw,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Lịch sử trò chuyện',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.wolf,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.isLoadingConversations && state.conversations.isEmpty) {
                    return Center(
                      child: DotLoadingIndicator(
                        color: AppColors.macaw,
                        size: 16.0,
                      ),
                    );
                  }

                  if (state.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: AppColors.hare,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có lịch sử',
                            style: TextStyle(
                              color: AppColors.wolf,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = state.conversations[index];
                      return FadeInRight(
                        delay: Duration(milliseconds: 300 + index * 100),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.macaw.withOpacity(0.15),
                            child: Icon(
                              Icons.chat_outlined,
                              color: AppColors.macaw,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            conversation.title.isNotEmpty
                                ? conversation.title
                                : 'Trò chuyện #${conversation.id.substring(0, 4)}',
                            style: TextStyle(
                              color: AppColors.eel,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _formatDate(conversation.createdAt),
                            style: TextStyle(
                              color: AppColors.wolf,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            context.read<ChatBloc>().add(
                              LoadConversationHistoryEvent(
                                conversationId: conversation.id,
                              ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
