import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_arena_page.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class VsClashScreen extends StatefulWidget {
  final BattleMatchEntity match;

  const VsClashScreen({super.key, required this.match});

  @override
  State<VsClashScreen> createState() => _VsClashScreenState();
}

class _VsClashScreenState extends State<VsClashScreen> {
  @override
  void initState() {
    super.initState();
    // Chuyển sang màn hình BattleArenaPage sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const BattleArenaPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161622),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background flash
          Flash(
            duration: const Duration(milliseconds: 800),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.macaw.withValues(alpha: 0.3),
                    const Color(0xFF161622),
                  ],
                  radius: 1.5,
                ),
              ),
            ),
          ),
          
          // Diagonal Split Line
          Positioned.fill(
            child: CustomPaint(
              painter: _ClashLinePainter(),
            ),
          ),

          // Player 1 (Left)
          Positioned(
            left: -50,
            top: MediaQuery.of(context).size.height * 0.2,
            child: SlideInLeft(
              duration: const Duration(milliseconds: 600),
              child: _buildPlayerAvatar(widget.match.player1, isLeft: true),
            ),
          ),

          // Player 2 (Right)
          Positioned(
            right: -50,
            bottom: MediaQuery.of(context).size.height * 0.2,
            child: SlideInRight(
              duration: const Duration(milliseconds: 600),
              child: _buildPlayerAvatar(widget.match.player2, isLeft: false),
            ),
          ),

          // VS Text with Lightning
          Center(
            child: ZoomIn(
              delay: const Duration(milliseconds: 500),
              duration: const Duration(milliseconds: 400),
              child: Pulse(
                infinite: true,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: AppColors.bee,
                      size: 200,
                    ),
                    Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppColors.cardinal,
                            blurRadius: 30,
                            offset: const Offset(4, 4),
                          ),
                          Shadow(
                            color: Colors.black,
                            blurRadius: 10,
                          ),
                        ],
                        fontFamily: 'DuolingoFeather',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(BattlePlayerEntity player, {required bool isLeft}) {
    final color = isLeft ? AppColors.macaw : AppColors.cardinal;
    
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: color,
              backgroundImage: player.profilePictureUrl != null && player.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(player.profilePictureUrl!)
                  : null,
              child: player.profilePictureUrl == null || player.profilePictureUrl!.isEmpty
                  ? Text(
                      player.displayName.isNotEmpty ? player.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                player.displayName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontFamily: 'DuolingoFeather',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
      
    final path = Path();
    // Draw a diagonal lightning split across the screen
    path.moveTo(size.width, 0);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(0, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
