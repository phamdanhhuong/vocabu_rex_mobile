import 'package:flutter/material.dart';

class DummyMiniGamePage extends StatelessWidget {
  const DummyMiniGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      appBar: AppBar(
        title: const Text("Mini Game Placeholder"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎮',
              style: TextStyle(fontSize: 100),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mini Game đang được tải...",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
              ),
              child: const Text("Quay lại Bản Đồ"),
            ),
          ],
        ),
      ),
    );
  }
}
