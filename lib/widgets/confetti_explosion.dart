import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiExplosion extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final bool isMobile;

  const ConfettiExplosion({
    Key? key,
    required this.child,
    this.trigger = true,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<ConfettiExplosion> createState() => _ConfettiExplosionState();
}

class _ConfettiExplosionState extends State<ConfettiExplosion>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late Animation<double> _explosionAnimation;

  final List<ConfettiParticle> _particles = [];
  final int particleCount = 20;

  @override
  void initState() {
    super.initState();

    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _explosionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeOut),
    );

    _initializeParticles();

    if (widget.trigger) {
      _explode();
    }
  }

  void _initializeParticles() {
    _particles.clear();
    final random = math.Random();

    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        ConfettiParticle(
          angle: (i / particleCount) * 2 * math.pi + random.nextDouble() * 0.5,
          speed: 50 + random.nextDouble() * 100,
          color: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
            Colors.pink,
            Colors.cyan,
          ][random.nextInt(8)],
          size: 2 + random.nextDouble() * 4,
          shape: random.nextInt(3),
        ),
      );
    }
  }

  void _explode() {
    _explosionController.reset();
    _explosionController.forward();
  }

  @override
  void didUpdateWidget(ConfettiExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _explode();
    }
  }

  @override
  void dispose() {
    _explosionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _explosionAnimation,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Confetti particles
            ..._particles.map((particle) => _buildParticle(particle)),

            // Main child
            widget.child,
          ],
        );
      },
    );
  }

  Widget _buildParticle(ConfettiParticle particle) {
    final progress = _explosionAnimation.value;
    final distance = particle.speed * progress;
    final gravity = progress * progress * 100; // Gravity effect

    final x = math.cos(particle.angle) * distance;
    final y = math.sin(particle.angle) * distance + gravity;

    final opacity = math.max(0.0, 1.0 - progress);
    final scale = 1.0 - (progress * 0.5);

    return Positioned(
      left: x,
      top: y,
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: progress * 4 * math.pi,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              color: particle.color.withOpacity(opacity),
              shape: particle.shape == 0 ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: particle.shape == 1
                  ? BorderRadius.circular(1)
                  : particle.shape == 2
                  ? BorderRadius.circular(particle.size / 2)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class ConfettiParticle {
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final int shape; // 0: circle, 1: square, 2: rounded square

  ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.shape,
  });
}
