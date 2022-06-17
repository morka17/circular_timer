import 'dart:math';

import 'package:flutter/material.dart';

class CircularTimer extends StatefulWidget {
  final Duration duration;
  final Offset offset;
  final bool outline;
  final Color color;
  final double outlinedWidth;

  /// **Start Angle must be in radian**
  ///like  ``` startAngle: 1.5 * math.pi ```
  final double startAngle;
  final double radius;
  final CircleDecoration? decoration;
  final double outlinedPadding;
  final bool repeat;

  const CircularTimer({
    Key? key,
    required this.duration,
    this.offset = const Offset(0, 0),
    this.outline = false,
    this.color = Colors.red,
    /// OutlinedWidth can be set to zero to make it form a border
    this.outlinedWidth = 4,
    required this.startAngle,
    required this.radius,
    this.decoration,
    this.outlinedPadding = 4.0,
    this.repeat = false,
  }) : super(key: key);

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _timerController;

  @override
  void initState() {
    _timerController =
        AnimationController(vsync: this, duration: widget.duration);
    final CurvedAnimation curve =
        CurvedAnimation(parent: _timerController, curve: Curves.easeIn);

    _animation = Tween(begin: 2.0, end: 0.0).animate(curve);
    _animation.addStatusListener(_repeat);
    _timerController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _repeat(AnimationStatus status) {
    if (widget.repeat) {
      if (status == AnimationStatus.dismissed) {
        _timerController.forward();
      } else if (status == AnimationStatus.completed) {
        _timerController.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: CircleTimerPainter(
            startAngle: widget.startAngle,
            sweepAngle: _animation.value * pi,
            offset: widget.offset,
            outlined: widget.outline,
            radius: widget.radius,
            color: widget.color,
            //outlinedColor: widget.decoration!.outlinedColor,
            outlinedPadding: widget.outlinedPadding,
            decoration: widget.decoration ?? CircleDecoration(),
            outlinedWidth: widget.outlinedWidth,
          ),
        );
      },
    );
  }
}

class CircleDecoration {
  final Color? outlinedColor;
  final Paint? outlineStyle;
  final Paint? circleStyle;

  CircleDecoration({
    this.outlinedColor,
    this.outlineStyle,
    this.circleStyle,
  });
}

class CircleTimerPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Offset offset;
  final bool outlined;
  final double radius;
  final Color color;
  final double outlinedPadding;
  final double outlinedWidth;
  final CircleDecoration decoration;

  CircleTimerPainter({
    required this.startAngle,
    required this.sweepAngle,
    this.offset = const Offset(0, 0),
    this.outlined = false,
    required this.radius,
    this.color = Colors.red,
    this.outlinedPadding = 4,
    required this.outlinedWidth,
    required this.decoration,
  });

  //TODO: Write the assertion for the construction paramaters:

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromCircle(center: offset, radius: radius);

    final Paint _strokeStyle = Paint()
      ..color =  decoration.outlinedColor ?? color
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlinedWidth;

    final Paint _fillStyle = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    arc(
        rect: rect,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        canvas: canvas,
        outlinedStyle: decoration.outlineStyle ?? _strokeStyle,
        fillStyle: decoration.circleStyle ?? _fillStyle);
  }

  void arc(
      {required Rect rect,
      required double startAngle,
      required double sweepAngle,
      required Canvas canvas,
      required Paint fillStyle,
      required Paint outlinedStyle}) {
    canvas.drawArc(rect, startAngle, sweepAngle, true, fillStyle);
    outlined
        ? canvas.drawCircle(offset, radius + outlinedPadding, outlinedStyle)
        : null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
