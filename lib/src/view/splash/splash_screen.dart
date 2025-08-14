import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller.forward();

    // Jab animation complete ho jaye, 0.5s ke baad login page pe jao
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(AppRoutes.login);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fullAppColor,
      body: Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: Image.asset(
            "assets/images/applogo.jpg",
            height: 200,
          ),
        ),
      ),
    );
  }
}
