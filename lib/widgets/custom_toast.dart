import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        final modalRoute = ModalRoute.of(context);
        final animation = modalRoute?.animation;

        Widget toastContent = Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSuccess
                    ? AppColors.success.withOpacity(0.9)
                    : AppColors.error.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              isSuccess
                  ? Lottie.asset(
                    'assets/success_check.json',
                    width: 30,
                    height: 30,
                    repeat: false,
                  )
                  : Lottie.asset(
                    'assets/error_cross.json',
                    width: 30,
                    height: 30,
                    repeat: false,
                  ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppStyles.toastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

        if (animation == null) {
          // No animation available, just show the toast without SlideTransition
          return Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Material(color: Colors.transparent, child: toastContent),
          );
        } else {
          // Animate the toast sliding down from top
          return Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: toastContent,
              ),
            ),
          );
        }
      },
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry != null && overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
