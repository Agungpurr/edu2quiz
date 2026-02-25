import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/guru/guru_dashboard.dart';
import 'screens/siswa/siswa_dashboard.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const EduQuizApp(),
    ),
  );
}

class EduQuizApp extends StatelessWidget {
  const EduQuizApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuiz SD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.isLoggedIn) return const LoginScreen();
        if (auth.isGuru)     return const GuruDashboard();
        return const SiswaDashboard();
      },
    );
  }
}
