import 'package:flutter/material.dart';

class LoadingDots extends StatefulWidget {
  final Color color;
  final double size;
  final double spacing;

  const LoadingDots({
    Key? key,
    this.color = const Color(0xFF4F46E5),
    this.size = 8.0,
    this.spacing = 4.0,
  }) : super(key: key);

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.size * _animations[index].value,
              height: widget.size * _animations[index].value,
              margin: EdgeInsets.only(right: index < 2 ? widget.spacing : 0),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.size / 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
