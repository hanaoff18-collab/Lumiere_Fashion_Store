import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Perspective matrix helper for subtle 3D transforms.
Matrix4 perspective3D({double rotateX = 0, double rotateY = 0, double depth = 0.001}) {
  return Matrix4.identity()
    ..setEntry(3, 2, depth)
    ..rotateX(rotateX)
    ..rotateY(rotateY);
}

/// Continuous gentle 3D float using [animation] 0→1 loop.
class Float3D extends StatelessWidget {
  const Float3D({
    super.key,
    required this.child,
    required this.animation,
    this.phase = 0,
    this.xAmp = 0.07,
    this.yAmp = 0.05,
  });

  final Widget child;
  final Animation<double> animation;
  final double phase;
  final double xAmp;
  final double yAmp;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final v = animation.value + phase;
        final t = v * math.pi * 2;
        final rx = math.sin(t) * xAmp;
        final ry = math.cos(t * 0.85) * yAmp;
        return Transform(
          alignment: Alignment.center,
          transform: perspective3D(rotateX: rx, rotateY: ry),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Frosted glass panel — modern “glassmorphism” stack.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 26,
    this.blur = 18,
    this.opacity = 0.22,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withValues(alpha: opacity),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: child,
        ),
      ),
    );
  }
}
