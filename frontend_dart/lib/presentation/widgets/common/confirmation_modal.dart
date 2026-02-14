import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Modal de confirmation stylé avec animation
/// Utilisable pour succès, erreur, info, etc.
class ConfirmationModal extends StatefulWidget {
  const ConfirmationModal({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.autoDismiss = true,
    this.dismissDuration = const Duration(seconds: 2),
  });

  final String message;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool autoDismiss;
  final Duration dismissDuration;

  @override
  State<ConfirmationModal> createState() => _ConfirmationModalState();
}

class _ConfirmationModalState extends State<ConfirmationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    if (widget.autoDismiss) {
      Future.delayed(widget.dismissDuration, () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) Navigator.of(context).pop();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo SahelArt (Favicon)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/branding/favicon_filled.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // Icon + Message
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.iconColor ?? AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // Subtitle (optionnel)
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper functions pour afficher les modals
class ConfirmationModalHelper {
  /// Affiche un modal de succès
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? subtitle,
    Duration? duration,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => ConfirmationModal(
        message: message,
        subtitle: subtitle,
        icon: Icons.check_circle,
        iconColor: const Color(0xFF10B981),
        dismissDuration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  /// Affiche un modal d'erreur
  static void showError(
    BuildContext context, {
    required String message,
    String? subtitle,
    Duration? duration,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => ConfirmationModal(
        message: message,
        subtitle: subtitle,
        icon: Icons.error,
        iconColor: const Color(0xFFEF4444),
        dismissDuration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un modal d'info
  static void showInfo(
    BuildContext context, {
    required String message,
    String? subtitle,
    Duration? duration,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => ConfirmationModal(
        message: message,
        subtitle: subtitle,
        icon: Icons.info,
        iconColor: const Color(0xFF3B82F6),
        dismissDuration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  /// Affiche un modal de panier (custom pour ajout au panier)
  static void showAddedToCart(
    BuildContext context, {
    required String productName,
    int quantity = 1,
    Duration? duration,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) => ConfirmationModal(
        message: 'Ajouté au panier !',
        subtitle: quantity > 1
            ? '$productName (×$quantity)'
            : productName,
        icon: Icons.shopping_bag,
        iconColor: AppColors.primary,
        dismissDuration: duration ?? const Duration(milliseconds: 1800),
      ),
    );
  }
}
