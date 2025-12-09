import 'dart:math';
import 'package:flutter/material.dart';

class GlitchButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final double height;

  const GlitchButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color = Colors.white,
    this.height = 60,
  });

  @override
  State<GlitchButton> createState() => _GlitchButtonState();
}

class _GlitchButtonState extends State<GlitchButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _isPressed ? 2.0 : 0.0;
          final glitchOffset = _isPressed ? Random().nextDouble() * 4 - 2 : 0.0;
          
          return Transform.translate(
            offset: Offset(glitchOffset, glitchOffset),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: _isPressed ? widget.color.withValues(alpha: 0.2) : Colors.black,
                border: Border.all(
                  color: widget.color,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: _isPressed ? 0.8 : 0.2),
                    blurRadius: _isPressed ? 10 : 0,
                    offset: Offset(4 - offset, 4 - offset),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glitch Lines
                  if (_isPressed || Random().nextDouble() > 0.95)
                    Positioned(
                      top: Random().nextDouble() * widget.height,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: widget.color,
                      ),
                    ),
                  Center(child: widget.child),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
