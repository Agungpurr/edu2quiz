import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/top_bar.dart';
import 'learning_path_screen.dart';
import 'riwayat_screen.dart';
import 'profil_tab.dart';

class SiswaDashboard extends StatefulWidget {
  const SiswaDashboard({super.key});
  @override
  State<SiswaDashboard> createState() => _SiswaDashboardState();
}

class _SiswaDashboardState extends State<SiswaDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: DuoColors.bg,
      appBar: DuoTopBar(
        xp: user?.xp ?? 0,
        streak: user?.streak ?? 0,
        hearts: user?.hearts ?? 4,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          LearningPathScreen(),
          RiwayatScreen(),
          ProfilTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: DuoColors.border, width: 2)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: '🏠', label: 'Belajar',  active: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: '📊', label: 'Riwayat', active: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
                _NavItem(icon: '👤', label: 'Profil',  active: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon, label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: active ? DuoColors.green : DuoColors.textGrey)),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 24 : 0, height: 3,
            decoration: BoxDecoration(color: DuoColors.green, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    ),
  );
}
