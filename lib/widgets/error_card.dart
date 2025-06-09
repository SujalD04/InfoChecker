import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class ErrorCard extends StatelessWidget {
  final String errorMessage;

  const ErrorCard({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      color: AppColors.error.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
        side: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(errorMessage, style: AppStyles.errorText)),
          ],
        ),
      ),
    );
  }
}
