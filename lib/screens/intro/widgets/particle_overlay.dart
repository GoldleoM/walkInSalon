import 'package:flutter/material.dart';

// --- Particle Overlay System ---

class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({super.key});

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final int _particleCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize random particles
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_Particle.random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(_particles, _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory _Particle.random() {
    return _Particle(
      x: (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0,
      y: (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0,
      size: ((DateTime.now().microsecondsSinceEpoch % 5) + 2).toDouble(),
      speed: ((DateTime.now().microsecondsSinceEpoch % 3) + 1) / 1000.0,
      opacity: ((DateTime.now().microsecondsSinceEpoch % 100) / 200.0) + 0.1,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
          .withValues(alpha: 0.4) // Gold dust
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Move particle upwards
      particle.y -= particle.speed;
      if (particle.y < 0) {
        particle.y = 1.0;
        particle.x = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0;
      }

      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      canvas.drawCircle(Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
