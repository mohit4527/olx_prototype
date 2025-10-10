import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';

class AidsScreen extends StatelessWidget {
  const AidsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aids'),
        backgroundColor: AppColors.appGreen,
      ),
      body: const Center(child: Text('Aids screen placeholder')),
    );
  }
}
