import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.danger,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
