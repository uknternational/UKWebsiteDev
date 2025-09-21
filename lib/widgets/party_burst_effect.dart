import 'package:flutter/material.dart';
import 'dart:math' as math;

class PartyBurstEffect extends StatefulWidget {
  final Widget child;
  final bool isMobile;

  const PartyBurstEffect({
    Key? key,
    required this.child,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<PartyBurstEffect> createState() => _PartyBurstEffectState();
}

class _PartyBurstEffectState extends State<PartyBurstEffect>
    with TickerProviderStateMixin {
  late AnimationController _burstController;
  late AnimationController _sparkleController;
  late AnimationController _floatController;

  late Animation<double> _burstAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Burst animation for explosion effect
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOutCirc),
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // Float animation for gentle movement
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start animations
    _burstController.repeat();
    _sparkleController.repeat();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _burstController.dispose();
    _sparkleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _burstAnimation,
        _sparkleAnimation,
        _floatAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Burst particles
            ...List.generate(12, (index) => _buildBurstParticle(index)),

            // Sparkle effects
            ...List.generate(8, (index) => _buildSparkleEffect(index)),

            // Floating shapes
            ...List.generate(4, (index) => _buildFloatingShape(index)),

            // Main child widget
            Transform.translate(
              offset: Offset(
                math.sin(_floatAnimation.value * 2 * math.pi) * 2,
                math.cos(_floatAnimation.value * 2 * math.pi) * 1,
              ),
              child: widget.child,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBurstParticle(int index) {
    final double angle = (index / 12) * 2 * math.pi;
    final double distance = _burstAnimation.value * (widget.isMobile ? 30 : 40);
    final double x = math.cos(angle) * distance;
    final double y = math.sin(angle) * distance;

    return Positioned(
      left: x,
      top: y,
      child: Transform.scale(
        scale: 1.0 - _burstAnimation.value,
        child: Container(
          width: widget.isMobile ? 3 : 4,
          height: widget.isMobile ? 3 : 4,
          decoration: BoxDecoration(
            color: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.pink,
              Colors.purple,
              Colors.blue,
            ][index % 6].withOpacity(1.0 - _burstAnimation.value),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSparkleEffect(int index) {
    final double animationOffset = index * 0.125;
    final double adjustedAnimation =
        (_sparkleAnimation.value + animationOffset) % 1.0;
    final double twinkle = math.sin(adjustedAnimation * 4 * math.pi);

    return Positioned(
      left:
          -25 + (index * 8) + (math.sin(adjustedAnimation * 2 * math.pi) * 20),
      top: -20 + (math.cos(adjustedAnimation * 3 * math.pi) * 15),
      child: Transform.scale(
        scale: 0.5 + (twinkle.abs() * 0.5),
        child: Icon(
          Icons.auto_awesome,
          size: widget.isMobile ? 8 : 10,
          color: Colors.yellow.withOpacity(twinkle.abs()),
        ),
      ),
    );
  }

  Widget _buildFloatingShape(int index) {
    final double animationOffset = index * 0.25;
    final double adjustedAnimation =
        (_floatAnimation.value + animationOffset) % 1.0;

    return Positioned(
      right: -15 - (index * 10),
      top: -10 + (math.sin(adjustedAnimation * 2 * math.pi) * 8),
      child: Transform.rotate(
        angle: adjustedAnimation * 2 * math.pi,
        child: Container(
          width: widget.isMobile ? 8 : 10,
          height: widget.isMobile ? 8 : 10,
          decoration: BoxDecoration(
            color: [
              Colors.red.withOpacity(0.6),
              Colors.blue.withOpacity(0.6),
              Colors.green.withOpacity(0.6),
              Colors.purple.withOpacity(0.6),
            ][index % 4],
            shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: index % 2 == 1 ? BorderRadius.circular(2) : null,
          ),
        ),
      ),
    );
  }
}
