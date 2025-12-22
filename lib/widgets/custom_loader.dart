import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:walkinsalonapp/core/app_config.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final bool isOverlay;

  const CustomLoader({super.key, this.size = 120, this.isOverlay = false});

  @override
  Widget build(BuildContext context) {
    final loader = Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child:
            ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return RadialGradient(
                      center: Alignment.center,
                      radius:
                          0.45, // Adjust radius to keep logo visible but fade edges
                      colors: [
                        Colors.white, // Fully visible at center
                        Colors.white,
                        Colors.transparent, // Fade to transparent at edges
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(AppImages.logoGold, fit: BoxFit.contain),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.15,
                  duration: 1.5.seconds,
                  curve: Curves.easeInOut,
                ) // Breathing scale
                .fadeIn(duration: 500.ms)
                .then()
                .shimmer(
                  duration: 2.seconds,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                ), // Gold shimmer
      ),
    );

    if (isOverlay) {
      return Container(
        color: Colors.black.withValues(alpha: 0.75), // Dim background
        child: loader,
      );
    }

    return loader;
  }
}
