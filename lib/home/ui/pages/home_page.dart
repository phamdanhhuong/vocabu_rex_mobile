import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/learning_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    context.read<HomeBloc>().add(GetUserProfileEvent());
  }

  Widget _buildLearningMapPage() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeSuccess && state.skillEntity != null) {
          return LearningMap(skillEntity: state.skillEntity!);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
      },
    );
  }

  List<Widget> get _pages => [
    _buildLearningMapPage(),
    Center(
      child: Text("Tìm kiếm", style: TextStyle(color: Colors.white)),
    ),
    Center(
      child: Text("Cài đặt", style: TextStyle(color: Colors.white)),
    ),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          current is HomeSuccess &&
          previous is! HomeSuccess &&
          current.skillEntity == null,
      listener: (context, state) {
        if (state is HomeSuccess && state.skillEntity == null) {
          // Lấy skillId từ userProgress và gọi GetSkillEvent
          final skillId = state.userProgressEntity.skillId;
          context.read<HomeBloc>().add(GetSkillEvent(id: skillId));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1612),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B0E0C),
          leading: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Builder(
              builder: (context) {
                return BlocConsumer<HomeBloc, HomeState>(
                  listenWhen: (previous, current) => current is HomeUnauthen,
                  listener: (context, state) {
                    if (state is HomeUnauthen) {
                      Navigator.pushReplacementNamed(context, "/login");
                    }
                  },
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return CircleAvatar(
                        backgroundImage: AssetImage("assets/avatar.jpg"),
                      );
                    } else if (state is HomeSuccess) {
                      return GestureDetector(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            state.userProfileEntity.profilePictureUrl,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, "/profile");
                        },
                      );
                    }
                    return const CircleAvatar(
                      backgroundImage: AssetImage("assets/avatar.jpg"),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                TokenManager.clearAccessToken();
                Navigator.pushReplacementNamed(context, "/login");
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey, // màu border
                width: 1, // độ dày border
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF0B0E0C),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
