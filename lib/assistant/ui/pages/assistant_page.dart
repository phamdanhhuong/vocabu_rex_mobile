import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/chat_bloc.dart';
import 'package:vocabu_rex_mobile/assistant/ui/widgets/chat_input.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isComposing = false;
  String _selectedMode = 'General'; // General, IELTS, TOEIC
  String _selectedRole = 'vocabulary_expert'; // Current selected role in dropdown
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
    context.read<ChatBloc>().add(SendMessageEvent(
      message: text,
      role: _selectedRole,
    ));
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    // Don't request focus to avoid keyboard popping back up
  }

  void _handleRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<FabCubit>().hide();
    
    // Initialize animation controller
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
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.macaw.withOpacity(0.1),
            AppColors.featherGreen.withOpacity(0.05),
            AppColors.snow,
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: AppColors.eel),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Text(
            'VocabuRex AI',
            style: TextStyle(
              color: AppColors.eel,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.history, color: AppColors.eel),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        drawer: _buildMainDrawer(),
        endDrawer: _buildConversationHistoryDrawer(),
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
        ), // Đóng ng
      ),
    );
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
                      border: Border.all(
                        color: AppColors.swan,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.macaw,
                          ),
                        ),
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
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.macaw : AppColors.polar,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUser ? AppColors.macaw : AppColors.swan,
                      width: 1,
                    ),
                  ),
                  child: MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        color: isUser ? AppColors.snow : AppColors.eel,
                      ),
                      code: TextStyle(
                        backgroundColor: AppColors.swan,
                        fontFamily: 'monospace',
                        color: AppColors.eel,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ChatInputBar(
          controller: _controller,
          focusNode: _focusNode,
          onSubmitted: _handleSubmitted,
          onChanged: (_) {}, // Keep for widget compatibility
          isComposing: _isComposing,
          selectedRole: _selectedRole,
          onRoleChanged: _handleRoleChanged,
        ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.macaw,
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing AI Assistant...',
            style: TextStyle(
              color: AppColors.wolf,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocaburexWelcomeScreen() {
    String userName = 'Hieu';
    final profileState = context.watch<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      userName = profileState.profile.displayName?.split(' ').last ?? 
                 profileState.profile.username;
    }

    return Stack(
      children: [
        // Main content with animation
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Hi $userName, Ready to practice?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.eel,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s improve your English together!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.wolf,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Mode Selector
              _buildModeSelector(),

              const SizedBox(height: 25),

              // Topic Suggestions
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildTopicChip('Daily Talk', Icons.chat_bubble_outline),
                  _buildTopicChip('Grammar', Icons.school_outlined),
                  _buildTopicChip('Vocabulary', Icons.library_books_outlined),
                  _buildTopicChip('Pronunciation', Icons.mic_outlined),
                  _buildTopicChip('Writing', Icons.edit_outlined),
                ],
              ),

              const SizedBox(height: 35),

              // Continue Learning Card
              _buildLearningCard(
                title: 'Continue Learning',
                icon: Icons.play_circle_outline,
                child: Column(
                  children: [
                    _buildHistoryItem('Lesson 5: Travel Vocabulary', 'Continue', AppColors.featherGreen),
                    const SizedBox(height: 10),
                    _buildHistoryItem('IELTS Speaking Practice', 'Resume', AppColors.macaw),
                    const SizedBox(height: 10),
                    _buildHistoryItem('Grammar Review: Past Tense', 'Review', AppColors.cardinal),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Learning Tools Card
              _buildLearningCard(
                title: 'Quick Access Tools',
                icon: Icons.apps_outlined,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildToolIcon(Icons.book_outlined, 'Dictionary', AppColors.macaw),
                      _buildToolIcon(Icons.style_outlined, 'Flashcard', AppColors.featherGreen),
                      _buildToolIcon(Icons.leaderboard_outlined, 'Leaderboard', AppColors.cardinal),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                'VocabuRex AI may make mistakes. Always verify important information.',
                style: TextStyle(color: AppColors.wolf, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ),
        // Positioned input box at bottom
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
                colors: [
                  AppColors.snow.withOpacity(0.0),
                  AppColors.snow,
                ],
              ),
            ),
            child: ChatInputBar(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _handleSubmitted,
              onChanged: (_) {}, // Keep for widget compatibility
              isComposing: _isComposing,
              selectedRole: _selectedRole,
              onRoleChanged: _handleRoleChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    final modes = ['General', 'IELTS', 'TOEIC'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.polar,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.swan),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((mode) {
          final isSelected = _selectedMode == mode;
          return GestureDetector(
            onTap: () => setState(() => _selectedMode = mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.featherGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                mode,
                style: TextStyle(
                  color: isSelected ? AppColors.snow : AppColors.wolf,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopicChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.swan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.hare.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.macaw, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.eel,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.swan, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.hare.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.featherGreen, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.eel,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String action, Color actionColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.polar,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.swan),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.book, color: actionColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.eel,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: actionColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              action,
              style: TextStyle(
                color: AppColors.snow,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.eel,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainDrawer() {
    return Drawer(
      backgroundColor: AppColors.snow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
            Divider(color: AppColors.swan),
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: AppColors.macaw),
              title: Text('New Conversation', style: TextStyle(color: AppColors.eel)),
              onTap: () {
                context.read<ChatBloc>().add(StartEvent());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppColors.wolf),
              title: Text('Settings', style: TextStyle(color: AppColors.eel)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationHistoryDrawer() {
    return Drawer(
      backgroundColor: AppColors.snow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppColors.macaw, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Chat History',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eel,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.swan),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.macaw),
                    );
                  }
                  
                  if (state is ConversationsLoaded) {
                    if (state.conversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, 
                              size: 64, 
                              color: AppColors.hare,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No conversations yet',
                              style: TextStyle(
                                color: AppColors.wolf,
                                fontSize: 16,
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
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.macaw.withOpacity(0.2),
                            child: Icon(
                              Icons.chat,
                              color: AppColors.macaw,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            conversation.title,
                            style: TextStyle(
                              color: AppColors.eel,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${conversation.messageCount} messages',
                            style: TextStyle(
                              color: AppColors.wolf,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.hare,
                          ),
                          onTap: () {
                            context.read<ChatBloc>().add(
                              LoadConversationHistoryEvent(
                                conversationId: conversation.id,
                              ),
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  
                  // Default: Load conversations
                  Future.microtask(() {
                    context.read<ChatBloc>().add(LoadConversationsEvent());
                  });
                  
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.macaw),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}