import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/data/services/mini_game_service.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class DummyMiniGamePage extends StatefulWidget {
  final String partId;
  final String type;

  const DummyMiniGamePage({super.key, required this.partId, required this.type});

  @override
  State<DummyMiniGamePage> createState() => _DummyMiniGamePageState();
}

class _DummyMiniGamePageState extends State<DummyMiniGamePage> {
  Map<String, dynamic>? _gameData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      final data = await MiniGameService().generateGame(widget.partId, widget.type);
      if (mounted) {
        setState(() {
          _gameData = data['data']; // Access the real data based on backend response interceptor structure if there is one
          // the backend usually returns { status: "success", data: ... } or just { ... }
          // We will use raw `data` for now. Wait, NestJS returns directly if no interceptor.
          _gameData = data['data'] ?? data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mini Game - ${widget.type.toUpperCase()}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red, fontSize: 16)),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🎮',
                        style: TextStyle(fontSize: 100),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Kỷ lục: ${_gameData?['bestStars'] ?? 0} Sao - ${_gameData?['bestScore'] ?? 0} Điểm',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Số lượng bài tập tạo ra: ${_gameData?['exercises']?.length ?? 0}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng Render màn hình Game Play thực tế sẽ được cập nhật sau!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text("BẮT ĐẦU CHƠI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                        ),
                        child: const Text("Quay lại Bản Đồ"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
