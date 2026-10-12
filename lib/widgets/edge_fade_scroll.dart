import 'package:flutter/material.dart';

/// Top edge fade for scroll feeds: content melts into the status-bar
/// region instead of hitting a hard background edge.
class EdgeFadeScroll extends StatelessWidget {
  final Widget child;
  final double fadeHeight;

  const EdgeFadeScroll({super.key, required this.child, this.fadeHeight = 28});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, fadeHeight));
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
