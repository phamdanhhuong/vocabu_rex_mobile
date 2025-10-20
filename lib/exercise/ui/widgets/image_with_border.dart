import 'package:flutter/material.dart';

class NetworkImageWithBorder extends StatelessWidget {
  final String imageUrl;

  const NetworkImageWithBorder({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300, // chiều rộng ảnh
        height: 300, // chiều cao ảnh
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue, // viền xanh dương
            width: 3, // độ dày viền
          ),
          borderRadius: BorderRadius.circular(16), // bo góc
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover, // cắt ảnh vừa khung
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error, color: Colors.red));
            },
          ),
        ),
      ),
    );
  }
}
