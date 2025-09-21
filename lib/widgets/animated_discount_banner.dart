import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'party_burst_effect.dart';

class AnimatedDiscountBanner extends StatefulWidget {
  final String discount;
  final String category;
  final bool isMobile;

  const AnimatedDiscountBanner({
    Key? key,
    required this.discount,
    required this.category,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<AnimatedDiscountBanner> createState() => _AnimatedDiscountBannerState();
}

class _AnimatedDiscountBannerState extends State<AnimatedDiscountBanner>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _confettiController;
  late AnimationController _balloonController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _balloonAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the banner
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    // Balloon animation
    _balloonController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _balloonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _balloonController, curve: Curves.elasticOut),
    );

    // Start animations
    _pulseController.repeat(reverse: true);
    _confettiController.repeat();
    _balloonController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    _balloonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _confettiAnimation,
        _balloonAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Floating confetti particles
            ...List.generate(6, (index) => _buildConfettiParticle(index)),

            // Balloon shapes
            ...List.generate(3, (index) => _buildBalloonShape(index)),

            // Main discount banner with burst effects
            PartyBurstEffect(
              isMobile: widget.isMobile,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 12 : 16,
                    vertical: widget.isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF4444),
                        Color(0xFFFF6B6B),
                        Color(0xFFFF8E8E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                      // Additional glow effect
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated star icon
                      Transform.rotate(
                        angle: _confettiAnimation.value * 2 * math.pi,
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: widget.isMobile ? 16 : 20,
                          shadows: [
                            Shadow(color: Colors.orange, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.discount}% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isMobile ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                            Shadow(
                              color: Colors.orange.withOpacity(0.3),
                              offset: const Offset(0, 0),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Animated sparkle with multiple effects
                      Transform.scale(
                        scale: 0.8 + (_pulseAnimation.value - 1) * 1.5,
                        child: Transform.rotate(
                          angle: _balloonAnimation.value * math.pi,
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.yellow,
                            size: widget.isMobile ? 14 : 18,
                            shadows: [
                              Shadow(color: Colors.orange, blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfettiParticle(int index) {
    final double animationOffset = index * 0.2;
    final double adjustedAnimation =
        (_confettiAnimation.value + animationOffset) % 1.0;

    return Positioned(
      left:
          -20 + (index * 15) + (math.sin(adjustedAnimation * 2 * math.pi) * 15),
      top: -15 + (math.cos(adjustedAnimation * 2 * math.pi) * 12),
      child: Transform.rotate(
        angle: adjustedAnimation * 6 * math.pi,
        child: Container(
          width: index % 2 == 0 ? 6 : 4,
          height: index % 3 == 0 ? 8 : 4,
          decoration: BoxDecoration(
            color: [
              Colors.yellow,
              Colors.orange,
              Colors.pink,
              Colors.purple,
              Colors.cyan,
              Colors.lime,
            ][index % 6],
            shape: index % 2 == 0 ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: index % 2 == 0 ? BorderRadius.circular(2) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildBalloonShape(int index) {
    final double animationOffset = index * 0.3;
    final double adjustedAnimation =
        (_balloonAnimation.value + animationOffset) % 1.0;

    return Positioned(
      right: -10 - (index * 8),
      top: -12 + (math.sin(adjustedAnimation * 2 * math.pi) * 5),
      child: Transform.scale(
        scale: 0.3 + (adjustedAnimation * 0.4),
        child: Container(
          width: 12,
          height: 16,
          decoration: BoxDecoration(
            color: [
              Colors.red.withOpacity(0.7),
              Colors.blue.withOpacity(0.7),
              Colors.green.withOpacity(0.7),
            ][index % 3],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
