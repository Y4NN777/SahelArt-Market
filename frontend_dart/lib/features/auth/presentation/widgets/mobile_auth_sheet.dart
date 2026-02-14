import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';

/// Modern animated bottom sheet for mobile authentication with drag gesture
class MobileAuthSheet extends StatefulWidget {
  const MobileAuthSheet({
    super.key,
    required this.child,
    required this.isExpanded,
    required this.onToggle,
    this.maxHeight = 680.0,
    this.collapsedHeight = 320.0,
  });

  final Widget child;
  final bool isExpanded;
  final VoidCallback onToggle;
  final double maxHeight;
  final double collapsedHeight;

  @override
  State<MobileAuthSheet> createState() => _MobileAuthSheetState();
}

class _MobileAuthSheetState extends State<MobileAuthSheet> {
  double _dragOffset = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta ?? 0;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final threshold = 50.0;

    if (widget.isExpanded) {
      // Si expanded, glisser vers le bas pour fermer
      if (_dragOffset > threshold || velocity > 500) {
        widget.onToggle();
      }
    } else {
      // Si collapsed, glisser vers le haut pour ouvrir
      if (_dragOffset < -threshold || velocity < -500) {
        widget.onToggle();
      }
    }

    setState(() {
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final actualHeight = widget.isExpanded ? widget.maxHeight : widget.collapsedHeight;

    return AnimatedPositioned(
      duration: AuthStyles.animationSlow,
      curve: AuthStyles.animationCurve,
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedPadding(
        duration: AuthStyles.animationNormal,
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: GestureDetector(
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: AnimatedContainer(
            duration: AuthStyles.animationSlow,
            curve: AuthStyles.animationCurve,
            height: actualHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFFDFBF7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AuthStyles.radiusXLarge + 8),
                topRight: Radius.circular(AuthStyles.radiusXLarge + 8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: [
                _SheetHandle(onTap: widget.onToggle),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AuthStyles.spacing12),
        child: Center(
          child: Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(AuthStyles.radiusPill),
            ),
          ),
        ),
      ),
    );
  }
}

/// Collapsed state content with call-to-action
class CollapsedSheetContent extends StatelessWidget {
  const CollapsedSheetContent({
    super.key,
    required this.onExpand,
    this.faviconAsset = 'assets/branding/favicon_filled.png',
  });

  final VoidCallback onExpand;
  final String faviconAsset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AuthStyles.spacing24,
        AuthStyles.spacing8,
        AuthStyles.spacing24,
        AuthStyles.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AuthStyles.spacing8),
          // Favicon avec shadow
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AuthStyles.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
              child: Image.asset(
                faviconAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AuthStyles.primary,
                      borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AuthStyles.spacing20),
          const Text(
            'Bienvenue sur SahelArt',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
              letterSpacing: -0.4,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AuthStyles.spacing8),
          const Text(
            'Connectez-vous pour découvrir l\'artisanat sahélien authentique',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AuthStyles.spacing24),
          // CTA Button
          _ExpandButton(onPressed: onExpand),
        ],
      ),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  const _ExpandButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthStyles.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AuthStyles.spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
          ),
          elevation: 2,
          shadowColor: AuthStyles.primary.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Commencer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: AuthStyles.spacing8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
