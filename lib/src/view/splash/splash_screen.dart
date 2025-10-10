import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    // Start asynchronous startup sequence: ensure token is loaded and
    // navigate to Home if user is logged in, otherwise to Login.
    _start();
  }

  Future<void> _start() async {
    try {
      final TokenController tokenController = Get.find<TokenController>();

      // Ensure token is loaded from shared preferences (safe to call even if already loaded)
      await tokenController.loadTokenFromStorage();

      // Keep splash visible for at least 3 seconds (video may be shorter/longer)
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      if (tokenController.isLoggedIn) {
        print("🔒 Found logged-in state - navigating to Home");
        Get.offAllNamed(AppRoutes.home);
      } else {
        print("🔓 No logged-in state - navigating to Login");
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print("⚠️ Splash startup error: $e");
      if (mounted) Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
