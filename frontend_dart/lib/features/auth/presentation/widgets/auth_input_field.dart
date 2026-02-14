import 'package:flutter/material.dart';
import '../styles/auth_styles.dart';

/// Reusable animated input field with consistent styling
class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool showPasswordToggle;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool enabled;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    _animationController = AnimationController(
      vsync: this,
      duration: AuthStyles.animationFast,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: _obscureText,
            enabled: widget.enabled,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827), // Noir plus foncé pour meilleure visibilité
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: TextStyle(
                color: _isFocused ? AuthStyles.primary : const Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AuthStyles.primary
                          : const Color(0xFF6B7280),
                      size: 22,
                    )
                  : null,
              suffixIcon: widget.showPasswordToggle
                  ? IconButton(
                      onPressed: _toggleObscureText,
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF6B7280),
                        size: 22,
                      ),
                      tooltip: _obscureText
                          ? 'Afficher le mot de passe'
                          : 'Masquer le mot de passe',
                    )
                  : null,
            ),
            validator: widget.validator,
            onTap: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
            },
          ),
        ],
      ),
    );
  }
}

/// Email validation helper
class EmailValidator {
  static String? validate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email requis';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v)) {
      return 'Format email invalide';
    }

    return null;
  }
}

/// Password validation helper
class PasswordValidator {
  static String? validate(String? value, {int minLength = 8}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Mot de passe requis';
    if (v.length < minLength) {
      return 'Minimum $minLength caractères';
    }
    return null;
  }
}
