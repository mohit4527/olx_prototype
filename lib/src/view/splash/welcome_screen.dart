import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _scaleController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color.fromARGB(255, 15, 15, 25),
                    Color.fromARGB(255, 25, 35, 65),
                  ]
                : [
                    Colors.white,
                    Color.fromARGB(255, 245, 248, 255),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background blobs
              Positioned(
                top: -50,
                right: -50,
                child: CustomPaint(
                  painter: BlobPainter(
                    progress: _floatingController.value,
                    color: AppColors.appGreen.withOpacity(0.08),
                    size: 200,
                  ),
                  size: const Size(250, 250),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -60,
                child: CustomPaint(
                  painter: BlobPainter(
                    progress: _floatingController.value,
                    color: AppColors.appPurple.withOpacity(0.06),
                    size: 180,
                  ),
                  size: const Size(280, 280),
                ),
              ),

              // Main content
              SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSizer().width6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo with shadow
                        AnimatedBuilder(
                          animation: Listenable.merge(
                              [_floatAnimation, _scaleAnimation]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnimation.value),
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Glow background
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.appGreen
                                                .withOpacity(0.25),
                                            blurRadius: 50,
                                            spreadRadius: 10,
                                          ),
                                          BoxShadow(
                                            color: AppColors.appPurple
                                                .withOpacity(0.1),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Rotating border ring
                                    CustomPaint(
                                      painter: RotatingRingPainter(
                                        progress: _floatingController.value,
                                        color: AppColors.appGreen
                                            .withOpacity(0.3),
                                      ),
                                      size: const Size(200, 200),
                                    ),
                                    // Logo image
                                    Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.appGreen
                                              .withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/OldMarketLogo.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: AppSizer().height3),

                        // Main heading with gradient
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                AppColors.appGreen,
                                AppColors.appPurple,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Welcome to Old Market',
                            style: TextStyle(
                              fontSize: AppSizer().fontSize24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: AppSizer().height2),

                        // Decorative line
                        Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.appGreen,
                                AppColors.appPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        SizedBox(height: AppSizer().height2),

                        // Subtitle with better styling
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer().width4,
                            vertical: AppSizer().height1,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.appGreen.withOpacity(0.08),
                                AppColors.appPurple.withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.appGreen.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Your gateway to buying and selling amazing products with ease and confidence',
                            style: TextStyle(
                              color: AppColors.appPurple,
                              fontSize: AppSizer().fontSize15,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: AppSizer().height4),

                        // Login button with enhanced styling
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.appGreen.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.login),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: AppColors.appGreen,
                                foregroundColor: AppColors.appWhite,
                                elevation: 0,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppSizer().height2),

                        // Sign up button with gradient border
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.appGreen.withOpacity(0.3),
                                AppColors.appPurple.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.signup_screen),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: AppColors.appGreen.withOpacity(0.5),
                                  width: 2,
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppColors.appGreen,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.appGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppSizer().height2),

                        // Additional info text
                        Text(
                          'New here? Create an account to get started',
                          style: TextStyle(
                            fontSize: AppSizer().fontSize13,
                            color: isDark
                                ? Colors.white38
                                : Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Blob painter for background animation
class BlobPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double size;

  BlobPainter({
    required this.progress,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    final x = centerX + math.sin(progress * 2 * math.pi) * 20;
    final y = centerY + math.cos(progress * 2 * math.pi) * 20;

    canvas.drawCircle(Offset(x, y), size, paint);
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Rotating ring painter
class RotatingRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  RotatingRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(progress * 4 * math.pi);

    // Draw dashed circle
    const dashWidth = 20;
    const dashSpace = 10;
    var currentAngle = 0.0;

    while (currentAngle < 2 * math.pi) {
      final startAngle = currentAngle;
      final endAngle = currentAngle + (dashWidth / radius);

      final startPoint = Offset(
        radius * math.cos(startAngle),
        radius * math.sin(startAngle),
      );
      final endPoint = Offset(
        radius * math.cos(endAngle),
        radius * math.sin(endAngle),
      );

      canvas.drawLine(startPoint, endPoint, paint);
      currentAngle += (dashWidth + dashSpace) / radius;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(RotatingRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}