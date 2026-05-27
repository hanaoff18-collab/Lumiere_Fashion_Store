import 'package:flutter/material.dart';

/// Subtle perspective tilt for a premium “3D” card feel.
class PerspectiveCard extends StatelessWidget {
  const PerspectiveCard({
    super.key,
    required this.child,
    this.tiltY = 0.04,
    this.depth = 0.0012,
  });

  final Widget child;
  final double tiltY;
  final double depth;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, depth)
        ..rotateY(tiltY),
      child: child,
    );
  }
}
