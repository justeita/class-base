import 'package:flutter/material.dart';

class SlideIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const SlideIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<SlideIndexedStack> createState() => _SlideIndexedStackState();
}

class _SlideIndexedStackState extends State<SlideIndexedStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _lastIndex;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.index;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(SlideIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _lastIndex = oldWidget.index;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          if (index == widget.index) {
             return SlideTransition(
               position: Tween<Offset>(
                 begin: Offset((index > _lastIndex) ? 1.0 : -1.0, 0),
                 end: Offset.zero,
               ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart)),
               child: child,
             );
          }
          
          if (index == _lastIndex && _controller.isAnimating) {
             return SlideTransition(
               position: Tween<Offset>(
                 begin: Offset.zero,
                 end: Offset((index < widget.index) ? -1.0 : 1.0, 0),
               ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart)),
               child: child,
             );
          }
          
          return Offstage(offstage: true, child: child);
        }),
      ],
    );
  }
}
