import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/utils/logger.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';

// 💡 Change 1: Renamed for clarity and to reflect advanced features
class AnimatedBrandedSplash extends StatefulWidget {
  const AnimatedBrandedSplash({super.key});

  @override
  State<AnimatedBrandedSplash> createState() => _AnimatedBrandedSplashState();
}

class _AnimatedBrandedSplashState extends State<AnimatedBrandedSplash>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<Offset> _logoSlide;
  late Animation<double> _fadeIn;
  late Animation<double> _glow;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulse;
  // 💡 Change 2: Added a secondary animation for a staggered effect
  late Animation<double> _subTextScale;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      // 💡 Change 3: Increased duration for a more deliberate, polished presentation
      duration: const Duration(milliseconds: 3500),
    );

    _pulseController = AnimationController(
      vsync: this,
      // 💡 Change 4: Faster pulse/more energetic feel
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Logo entrance with spring effect - Kept the elasticOut for high impact
    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Smooth rotation - Increased rotation magnitude
    _logoRotate = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.0,
          0.45,
          curve: Curves.easeOutCubic,
        ), // 💡 New Curve
      ),
    );

    // Logo slide from top - Adjusted offset for more vertical movement
    _logoSlide = Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.easeOutExpo,
            ), // 💡 New Curve for dramatic entry
          ),
        );

    // Overall fade in - Made it start earlier and longer
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    // Glow intensity
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Text slide up - Adjusted interval to start later, after logo stabilizes
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(
              0.5,
              1.0,
              curve: Curves.easeOutCubic,
            ), // 💡 New Curve
          ),
        );

    // 💡 Change 5: New animation for subtext, scales up slightly
    _subTextScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse for loader
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      // 💡 Smaller pulse range
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _start();
  }

  Future<void> _start() async {
    try {
      final TokenController tokenController = Get.find<TokenController>();

      final futures = <Future<void>>[
        _mainController.forward(),
        tokenController.loadTokenFromStorage(),
      ];

      await Future.wait(futures);

      if (!mounted) return;

      // 💡 Change 6: Reduced the post-animation delay slightly as the animation is longer
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (tokenController.isLoggedIn) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.welcome);
      }
    } catch (e) {
      debugPrint("⚠ Splash startup error: $e");
      if (mounted) Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger.d('Splash', 'build start - size=${MediaQuery.of(context).size}');
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 💡 Change 7: Use the theme's background color if available, or a defined color
      backgroundColor: isDark
          ? const Color.fromARGB(255, 10, 12, 30) // Dark start color
          : Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // 💡 Change 8: More subtle, yet deep background gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color.fromARGB(255, 8, 10, 25),
                    const Color.fromARGB(255, 20, 25, 50),
                    const Color.fromARGB(255, 8, 10, 25),
                  ]
                : [
                    Colors.white,
                    const Color.fromARGB(255, 235, 240, 250),
                    Colors.white,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background elements (Orbitals)
              // 💡 Change 9: Slightly adjusted orbital sizes/opacities for better visual hierarchy
              Positioned(
                top: -120, // Pushed further out
                right: -120,
                child: AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle:
                          _mainController.value * 2.5 * math.pi, // Faster spin
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              primary.withOpacity(
                                0.18,
                              ), // Slightly stronger opacity
                              primary.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.08),
                              blurRadius: 60,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: -100, // Pushed further out
                left: -100,
                child: AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle:
                          -_mainController.value *
                          2.0 *
                          math.pi, // Faster counter-spin
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              secondary.withOpacity(
                                0.15,
                              ), // Slightly stronger opacity
                              secondary.withOpacity(0.03),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Particle background
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: ParticleBgPainter(
                      progress: _mainController.value,
                      primary: primary,
                      secondary: secondary,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, _) {
                    Logger.d(
                      'Splash',
                      'AnimatedBuilder rebuild - mainController=${_mainController.value}',
                    );
                    return Opacity(
                      opacity: _fadeIn.value,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo with advanced effects
                            SlideTransition(
                              position: _logoSlide,
                              child: Transform.rotate(
                                angle: _logoRotate.value,
                                child: Transform.scale(
                                  scale: _logoScale.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Dynamic glow layers
                                      AnimatedBuilder(
                                        animation: _glow,
                                        builder: (context, child) {
                                          return Container(
                                            width:
                                                240 +
                                                (30 *
                                                    _glow
                                                        .value), // Bigger max glow size
                                            height: 240 + (30 * _glow.value),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primary.withOpacity(
                                                    0.6 * _glow.value,
                                                  ), // Stronger primary glow
                                                  blurRadius:
                                                      80 *
                                                      _glow
                                                          .value, // More blurred
                                                  spreadRadius:
                                                      25 * _glow.value,
                                                ),
                                                BoxShadow(
                                                  color: secondary.withOpacity(
                                                    0.3 * _glow.value,
                                                  ),
                                                  blurRadius: 50 * _glow.value,
                                                  spreadRadius: 15,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),

                                      // Multiple rotating rings
                                      ...[
                                        (
                                          0.5,
                                          230.0,
                                          1.8,
                                        ), // Adjusted size and speed
                                        (0.7, 270.0, -1.2),
                                        (0.9, 310.0, 0.9),
                                      ].map((ringData) {
                                        final (opacity, size, speed) = ringData;
                                        return Transform.rotate(
                                          angle:
                                              _mainController.value *
                                              speed *
                                              2 *
                                              math.pi,
                                          child: Container(
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: primary.withOpacity(
                                                  opacity * _glow.value * 0.7,
                                                ),
                                                width:
                                                    1.8, // Slightly thicker border
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),

                                      // Main logo container
                                      Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primary.withOpacity(0.25),
                                            width: 4, // Thicker border
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black87
                                                  : Colors.grey.withOpacity(
                                                      0.3,
                                                    ), // 💡 Change 10: Subtle outer shadow on logo
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          // 💡 Change 11: Added a slight color filter/tint to the image
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              primary.withOpacity(0.05),
                                              BlendMode.srcATop,
                                            ),
                                            child: Image.asset(
                                              "assets/images/OldMarketLogo.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 60),

                            // Animated text content
                            SlideTransition(
                              position: _textSlide,
                              child: Opacity(
                                opacity: _fadeIn.value,
                                child: Column(
                                  children: [
                                    // Title with gradient
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: [primary, secondary],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        'Old Market',
                                        style: TextStyle(
                                          fontSize:
                                              52, // 💡 Change 12: Bigger title
                                          fontWeight: FontWeight
                                              .w900, // Slightly lighter weight
                                          color: Colors
                                              .white, // Color is masked by Shader
                                          letterSpacing:
                                              -1.5, // Tighter spacing
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ), // Reduced spacing
                                    // Animated underline
                                    Container(
                                      width:
                                          100 *
                                          _fadeIn.value, // Longer underline
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [primary, secondary],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primary.withOpacity(
                                              0.6,
                                            ), // Stronger shadow
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 25,
                                    ), // Increased spacing
                                    // Subtitle with scaling
                                    Transform.scale(
                                      scale: _subTextScale.value,
                                      child: Text(
                                        'Your Trusted Marketplace',
                                        style: TextStyle(
                                          fontSize: 18, // Bigger subtitle
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          letterSpacing: 1.0,
                                          shadows: [
                                            Shadow(
                                              // 💡 Change 13: Subtitle subtle shadow
                                              color: Colors.black.withOpacity(
                                                isDark ? 0.4 : 0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Tagline with badge - Slightly softened colors/borders
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32, // More padding
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          colors: [
                                            primary.withOpacity(
                                              0.08,
                                            ), // Reduced opacity
                                            secondary.withOpacity(0.06),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: primary.withOpacity(
                                            0.2,
                                          ), // Reduced border opacity
                                          width: 1.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primary.withOpacity(0.05),
                                            blurRadius: 10, // Less blur
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'BUY • SELL • DISCOVER',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w800, // Bolder tagline
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          letterSpacing: 1.8, // Wider spacing
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 80),

                            // Enhanced loading indicator
                            Transform.scale(
                              scale: _pulse.value,
                              child: SizedBox(
                                width: 60, // Slightly bigger loader
                                height: 60,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Background circle with subtle shadow
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primary.withOpacity(
                                          isDark ? 0.1 : 0.05,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primary.withOpacity(0.15),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Main progress indicator
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        primary,
                                      ),
                                      strokeWidth: 4.0, // Thicker stroke
                                      backgroundColor: primary.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 15), // Reduced spacing
                            // Loading text
                            Text(
                              'Securing your connection...', // 💡 Change 14: More professional loading text
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: primary, // Full primary color
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced particle background painter
class ParticleBgPainter extends CustomPainter {
  final double progress;
  final Color primary;
  final Color secondary;

  ParticleBgPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Orbiting particles
    for (int i = 0; i < 20; i++) {
      // 💡 Change 15: More particles
      final angle = (i / 20) * 2 * math.pi + (progress * 5); // Faster rotation
      final distance = 100 + (progress * 150); // Larger orbit path
      final x = centerX + math.cos(angle) * distance;
      final y = centerY + math.sin(angle) * distance;

      final particleSize = 2.0 + (progress * 3); // Larger max particle size
      paint.color = (i % 2 == 0 ? primary : secondary).withOpacity(
        (0.8 - (progress * 0.4)).clamp(0.2, 0.8), // Adjusted opacity range
      );

      // 💡 Change 16: Radial gradient for particles for a glow effect
      paint.shader =
          RadialGradient(
            colors: [paint.color, paint.color.withOpacity(0.1)],
          ).createShader(
            Rect.fromCircle(center: Offset(x, y), radius: particleSize),
          );

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    paint.shader = null; // Clear shader for lines

    // Subtle connecting lines - Only draw if progress is well underway
    if (progress > 0.4) {
      // Later start for lines
      paint
        ..color = primary
            .withOpacity(
              (0.15 * progress).clamp(0.0, 0.2),
            ) // Fades in with progress
        ..strokeWidth = 1.0;

      for (int i = 0; i < 20; i++) {
        final angle1 = (i / 20) * 2 * math.pi + (progress * 5);
        final angle2 =
            ((i + 3) / 20) * 2 * math.pi +
            (progress *
                5); // Connect to a particle further away for a web effect
        final distance = 100 + (progress * 150);

        final x1 = centerX + math.cos(angle1) * distance;
        final y1 = centerY + math.sin(angle1) * distance;
        final x2 = centerX + math.cos(angle2) * distance;
        final y2 = centerY + math.sin(angle2) * distance;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticleBgPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
