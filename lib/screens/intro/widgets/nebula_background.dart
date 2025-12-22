import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NebulaBackground extends StatelessWidget {
  const NebulaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep base
        Container(color: const Color(0xFF141414)),

        // Glowing Orbs (Nebula effect)
        Positioned(
          top: -50,
          left: -50,
          child:
              _GlowingOrb(
                    color: Colors.purple.withValues(alpha: 0.15),
                    size: 300,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                    duration: 8.seconds,
                  )
                  .move(
                    begin: const Offset(0, 0),
                    end: const Offset(30, 30),
                    duration: 10.seconds,
                  ),
        ),

        Positioned(
          bottom: -100,
          right: -50,
          child:
              _GlowingOrb(
                    color: const Color.fromARGB(
                      255,
                      20,
                      142,
                      241,
                    ).withValues(alpha: 0.15),
                    size: 400,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1, 1),
                    duration: 9.seconds,
                  )
                  .move(
                    begin: const Offset(0, 0),
                    end: const Offset(-40, -40),
                    duration: 12.seconds,
                  ),
        ),

        Positioned(
          top: 100,
          right: 50,
          child:
              _GlowingOrb(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    size: 150,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 2.seconds)
                  .moveY(begin: 0, end: -50, duration: 6.seconds),
        ),

        // Blur overlay to diffuse them
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _GlowingOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowingOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 50, spreadRadius: 10)],
      ),
    );
  }
}
