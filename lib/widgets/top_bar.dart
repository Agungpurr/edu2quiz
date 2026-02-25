import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DuoTopBar extends StatelessWidget implements PreferredSizeWidget {
  final int xp;
  final int streak;
  final int hearts;

  const DuoTopBar({super.key, required this.xp, required this.streak, required this.hearts});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('🦉', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 6),
          const Text('EduQuiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: DuoColors.green)),
          const Spacer(),
          _StatPill(emoji: '🔥', value: '$streak', bg: const Color(0xFFFFF4E0), textColor: DuoColors.orange),
          const SizedBox(width: 8),
          _StatPill(emoji: '❤️', value: '$hearts', bg: const Color(0xFFFFF0F0), textColor: DuoColors.red),
          const SizedBox(width: 8),
          _StatPill(emoji: '⭐', value: '$xp', bg: const Color(0xFFFFFBE0), textColor: DuoColors.orange),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final Color bg;
  final Color textColor;

  const _StatPill({required this.emoji, required this.value, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 15)),
        ],
      ),
    );
  }
}
