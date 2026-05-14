import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: [

          _NavItem(
            icon: Icons.home,
            label: "Inicio",
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),

          _NavItem(
            icon: Icons.explore,
            label: "Explora",
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),

          _NavItem(
            icon: Icons.mail,
            label: "Solicitudes",
            active: currentIndex == 2,
            onTap: () => onTap(2),
          ),

          _NavItem(
            icon: Icons.person,
            label: "Perfil",
            active: currentIndex == 3,
            onTap: () => onTap(3),
          ),

        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    active ? Colors.orange : Colors.white54;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
              active ? FontWeight.w700 : null,
            ),
          ),

        ],
      ),
    );
  }
}