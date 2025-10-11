import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String languageCode;
  final int streak;
  final int gem;
  final int energy;
  final int coin;
  final VoidCallback onLogout;

  const HomeAppBar({
    Key? key,
    required this.languageCode,
    required this.streak,
    required this.gem,
    required this.energy,
    required this.coin,
    required this.onLogout,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarColor,
      elevation: 0,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/flags/$languageCode.png',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.language, color: Colors.white),
          ),
        ),
      ),
      title: Row(
        children: [
          _InfoItem(icon: Icons.local_fire_department, value: streak.toString()),
          const SizedBox(width: 8),
          _InfoItem(icon: Icons.diamond, value: gem.toString(), color: Colors.blueAccent),
          const SizedBox(width: 8),
          _InfoItem(icon: Icons.bolt, value: energy.toString(), color: Colors.pinkAccent),
          const SizedBox(width: 8),
          _InfoItem(icon: Icons.monetization_on, value: coin.toString(), color: Colors.amber),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color? color;

  const _InfoItem({
    Key? key,
    required this.icon,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 20),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
