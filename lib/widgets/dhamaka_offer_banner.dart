import 'package:flutter/material.dart';
import 'dart:math' as math;

class DhamakaOfferBanner extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;

  const DhamakaOfferBanner({
    Key? key,
    required this.isMobile,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<DhamakaOfferBanner> createState() => _DhamakaOfferBannerState();
}

class _DhamakaOfferBannerState extends State<DhamakaOfferBanner>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _burstController;
  late AnimationController _rotationController;
  late AnimationController _popperController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _burstAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _popperAnimation;

  @override
  void initState() {
    super.initState();

    // Font pulsing animation (bigger to smaller)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Burst background animation
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _burstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _burstController, curve: Curves.easeOut));
    _burstController.repeat();

    // Rotation animation for burst elements
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _rotationController.repeat();

    // Party popper animation
    _popperController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _popperAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popperController, curve: Curves.easeOut),
    );
    _popperController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _burstController.dispose();
    _rotationController.dispose();
    _popperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate size as 1/3rd of screen height for better visibility
    final screenHeight = MediaQuery.of(context).size.height;
    final logoSize =
        screenHeight *
        0.4; // Increased to 40% of screen height to match Dhamaka Offer

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: widget.isMobile ? 16.0 : 24.0,
        horizontal: widget.isMobile ? 16.0 : 32.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // UK International Logo - Left side, using existing logo
          Flexible(
            flex: 1,
            child: SizedBox(
              width: logoSize,
              height: logoSize,
              child: _buildExistingLogo(logoSize),
            ),
          ),
          const SizedBox(width: 16), // Add spacing between elements
          // Dhamaka Offer - Right side, same size as logo
          Flexible(
            flex: 1,
            child: SizedBox(
              width: logoSize,
              height: logoSize,
              child: _buildDhamakaOffer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingLogo(double size) {
    return Container(
      width: size,
      height: size,
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.fitWidth, // Fill width while maintaining aspect ratio
        errorBuilder: (context, error, stackTrace) {
          // Fallback if logo is not available
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[300]!, Colors.amber[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: size * 0.4, // Scale icon with container size
            ),
          );
        },
      ),
    );
  }

  Widget _buildDhamakaOffer() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _burstAnimation,
        _rotationAnimation,
        _popperAnimation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: DhamakaBurstPainter(
            pulseValue: _pulseAnimation.value,
            burstValue: _burstAnimation.value,
            rotationValue: _rotationAnimation.value,
            popperValue: _popperAnimation.value,
            isMobile: widget.isMobile,
          ),
          child: Center(
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DHAMAKA',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 16.0 : 18.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'OFFER',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 12.0 : 14.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DhamakaBurstPainter extends CustomPainter {
  final double pulseValue;
  final double burstValue;
  final double rotationValue;
  final double popperValue;
  final bool isMobile;

  DhamakaBurstPainter({
    required this.pulseValue,
    required this.burstValue,
    required this.rotationValue,
    required this.popperValue,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Create starburst background
    _drawStarburst(canvas, center, size, paint);

    // Draw party popper effects
    _drawPartyPoppers(canvas, center, size, paint);

    // Draw sparkles and confetti
    _drawSparkles(canvas, center, size, paint);
  }

  void _drawStarburst(Canvas canvas, Offset center, Size size, Paint paint) {
    final path = Path();
    final baseRadius = size.width * 0.4;
    final spikeLength = size.width * 0.15;
    const int numSpikes = 8; // Back to 8 spikes for more dynamic look

    // Create dynamic starburst shape with sharp, energetic edges
    for (int i = 0; i < numSpikes * 2; i++) {
      final double angle = (math.pi / numSpikes) * i + rotationValue * 0.5;
      final double radius = (i % 2 == 0)
          ? baseRadius
          : baseRadius + spikeLength * burstValue;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill with red gradient
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFE53E3E), // Red
        const Color(0xFFC53030), // Darker red
        const Color(0xFF9B2C2C), // Even darker red
      ],
      stops: [0.0, 0.7, 1.0],
    );
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: size.width * 0.5),
    );
    canvas.drawPath(path, paint);

    // Add yellow outline
    paint.shader = null;
    paint.color = Colors.yellow[400]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawPath(path, paint);
  }

  void _drawPartyPoppers(Canvas canvas, Offset center, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;

    // Draw multiple party popper particles - increased count and area
    for (int i = 0; i < 32; i++) {
      // Increased from 16 to 32
      final angle =
          (i * 11.25 + rotationValue * 45) * math.pi / 180; // More particles
      final distance = 60.0 * popperValue; // Increased from 40 to 60
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Colors matching the Diwali banner reference - more colors
      final colors = [
        Colors.purple,
        Colors.pink,
        Colors.yellow,
        Colors.lightBlue,
        Colors.green,
        Colors.orange,
        Colors.red,
        Colors.blue,
        Colors.cyan,
        Colors.lime,
        Colors.indigo,
        Colors.teal,
      ];
      paint.color = colors[i % colors.length].withOpacity(0.9 * popperValue);

      // Draw circles of varying sizes like confetti - more variety
      final radius = (1.5 + (i % 4) * 0.8) * popperValue; // More size variation
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Add scattered confetti around the burst - increased area and count
    for (int i = 0; i < 16; i++) {
      // Increased from 8 to 16
      final randomX =
          center.dx +
          (math.sin(popperValue * 2 * math.pi + i) *
              size.width *
              0.5); // Increased area
      final randomY =
          center.dy +
          (math.cos(popperValue * 2 * math.pi + i) *
              size.height *
              0.5); // Increased area

      final colors = [
        Colors.purple,
        Colors.pink,
        Colors.yellow,
        Colors.lightBlue,
        Colors.cyan,
        Colors.lime,
      ];
      paint.color = colors[i % colors.length].withOpacity(0.8 * popperValue);
      canvas.drawCircle(
        Offset(randomX, randomY),
        (1.0 + (i % 3) * 0.5) * popperValue,
        paint,
      );
    }

    // Add extra burst particles for more pop
    for (int i = 0; i < 12; i++) {
      final burstAngle = (i * 30.0 + rotationValue * 60) * math.pi / 180;
      final burstDistance = 80.0 * popperValue; // Even larger area
      final burstX = center.dx + math.cos(burstAngle) * burstDistance;
      final burstY = center.dy + math.sin(burstAngle) * burstDistance;

      final burstColors = [
        Colors.purple,
        Colors.pink,
        Colors.yellow,
        Colors.cyan,
      ];
      paint.color = burstColors[i % burstColors.length].withOpacity(
        0.7 * popperValue,
      );
      canvas.drawCircle(Offset(burstX, burstY), 2.0 * popperValue, paint);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;

    // Draw sparkles around the burst
    for (int i = 0; i < 8; i++) {
      final sparkleAngle = (i * 45.0 + rotationValue * 45) * math.pi / 180;
      final sparkleDistance = 25.0 * popperValue;
      final sparkleX = center.dx + math.cos(sparkleAngle) * sparkleDistance;
      final sparkleY = center.dy + math.sin(sparkleAngle) * sparkleDistance;

      paint.color = Colors.white.withOpacity(0.9 * popperValue);
      canvas.drawCircle(Offset(sparkleX, sparkleY), 1.5 * popperValue, paint);
    }

    // Draw central burst
    paint.color = Colors.yellow[300]!.withOpacity(0.7 * popperValue);
    canvas.drawCircle(center, 6.0 * popperValue, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
