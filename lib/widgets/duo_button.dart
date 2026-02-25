import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DuoButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final double? width;

  const DuoButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.color = DuoColors.green,
    this.shadowColor = DuoColors.greenDark,
    this.textColor = Colors.white,
    this.width,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && !widget.loading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) { setState(() => _pressed = false); widget.onTap!(); } : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: widget.width ?? double.infinity,
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: !enabled ? DuoColors.textGrey : widget.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed || !enabled ? [] : [
            BoxShadow(color: widget.shadowColor, offset: const Offset(0, 4), blurRadius: 0),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: widget.loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(widget.label, style: TextStyle(color: !enabled ? Colors.white60 : widget.textColor, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

class DuoOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const DuoOutlineButton({super.key, required this.label, this.onTap, this.color = DuoColors.green});

  @override
  State<DuoOutlineButton> createState() => _DuoOutlineButtonState();
}

class _DuoOutlineButtonState extends State<DuoOutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DuoColors.border, width: 2),
          boxShadow: _pressed ? [] : [const BoxShadow(color: DuoColors.border, offset: Offset(0, 3), blurRadius: 0)],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text(widget.label, style: const TextStyle(color: DuoColors.textGrey, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5))),
      ),
    );
  }
}
