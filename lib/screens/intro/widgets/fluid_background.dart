import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FluidBackground extends StatelessWidget {
  const FluidBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base white
        Container(color: Colors.white),

        // Moving Blobs
        Positioned(
          top: -100,
          right: -100,
          child:
              _FluidBlob(color: Colors.blue.withValues(alpha: 0.05), size: 400)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .move(
                    begin: const Offset(0, 0),
                    end: const Offset(-50, 50),
                    duration: 8.seconds,
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 6.seconds,
                  ),
        ),

        Positioned(
          top: 300,
          left: -100,
          child:
              _FluidBlob(
                    color: Colors.purple.withValues(alpha: 0.05),
                    size: 500,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .move(
                    begin: const Offset(0, 0),
                    end: const Offset(50, -30),
                    duration: 10.seconds,
                  )
                  .rotate(begin: 0, end: 0.1, duration: 12.seconds),
        ),

        Positioned(
          bottom: -50,
          right: 50,
          child:
              _FluidBlob(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
                    size: 300,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .move(
                    begin: const Offset(0, 0),
                    end: const Offset(-30, -50),
                    duration: 7.seconds,
                  )
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 5.seconds,
                  ),
        ),

        // Blur overlay to mash them together
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            color: Colors.white.withValues(alpha: 0.3),
          ), // Glass layer
        ),
      ],
    );
  }
}

class _FluidBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _FluidBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
