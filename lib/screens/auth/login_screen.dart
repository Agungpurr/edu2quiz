import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showError('Username dan password harus diisi!');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text.trim());
    if (!ok && mounted) _showError(auth.error ?? 'Login gagal');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800)),
      backgroundColor: DuoColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Green owl header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: DuoColors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.elliptical(200, 60),
                bottomRight: Radius.elliptical(200, 60),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Text('🦉', style: TextStyle(fontSize: 54))),
                ),
                const SizedBox(height: 16),
                const Text('EduQuiz',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                const Text('Belajar Seru Tiap Hari! ✨',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text('USERNAME',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: DuoColors.textGrey,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameCtrl,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                    decoration:
                        const InputDecoration(hintText: 'Masukkan username'),
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 16),
                  const Text('PASSWORD',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: DuoColors.textGrey,
                          letterSpacing: 1)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: DuoColors.textGrey),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 28),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => _DuoButton(
                      label: 'MASUK',
                      loading: auth.isLoading,
                      onTap: _login,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuoButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  final Color color;
  final Color shadowColor;

  const _DuoButton({
    required this.label,
    required this.onTap,
    this.loading = false,
    this.color = DuoColors.green,
    this.shadowColor = DuoColors.greenDark,
  });

  @override
  State<_DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<_DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.loading ? DuoColors.textGrey : widget.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                      color: widget.shadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0),
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
        ),
      ),
    );
  }
}
