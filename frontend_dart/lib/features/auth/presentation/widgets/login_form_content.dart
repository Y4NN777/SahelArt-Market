import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../presentation/widgets/common/app_button.dart';
import '../styles/auth_styles.dart';
import 'auth_branding_header.dart';
import 'auth_input_field.dart';

/// Main login form content - reusable across mobile and desktop
class LoginFormContent extends StatefulWidget {
  const LoginFormContent({
    super.key,
    required this.onSubmit,
    required this.onGoToRegister,
    required this.loading,
    this.error,
    this.apiBaseUrl,
    this.showClose = false,
    this.onClose,
    this.rememberMeInitial = false,
    this.onSkip,
  });

  final Future<void> Function(String email, String password, bool rememberMe) onSubmit;
  final VoidCallback onGoToRegister;
  final VoidCallback? onSkip;
  final bool loading;
  final String? error;
  final String? apiBaseUrl;
  final bool showClose;
  final VoidCallback? onClose;
  final bool rememberMeInitial;

  @override
  State<LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<LoginFormContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController(
    text: kDebugMode ? 'customer@example.com' : '',
  );
  final TextEditingController _passwordCtrl = TextEditingController(
    text: kDebugMode ? 'SecurePass123' : '',
  );
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _rememberMe = widget.rememberMeInitial;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await widget.onSubmit(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      _rememberMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: AuthBrandingHeader(showPill: false),
              ),
              if (widget.showClose)
                IconButton(
                  onPressed: widget.loading ? null : widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Fermer',
                ),
            ],
          ),

          const SizedBox(height: AuthStyles.spacing8),

          // Title & Subtitle
          const Text(
            'Connexion',
            style: AuthStyles.cardTitle,
          ),
          const SizedBox(height: AuthStyles.spacing4),
          const Text(
            'Accédez à votre espace artisanat',
            style: AuthStyles.cardSubtitle,
          ),

          const SizedBox(height: AuthStyles.spacing24),

          // Email field
          AuthInputField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            label: 'Email',
            hint: 'votre@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: EmailValidator.validate,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Password field
          AuthInputField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            label: 'Mot de passe',
            hint: 'Minimum 8 caractères',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.done,
            validator: (value) => PasswordValidator.validate(value),
            onFieldSubmitted: (_) => _handleSubmit(),
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing12),

          // Remember me checkbox
          InkWell(
            onTap: widget.loading
                ? null
                : () => setState(() => _rememberMe = !_rememberMe),
            borderRadius: BorderRadius.circular(AuthStyles.radiusSmall),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AuthStyles.spacing4),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: widget.loading
                          ? null
                          : (value) => setState(() => _rememberMe = value ?? false),
                      activeColor: AuthStyles.primary,
                      checkColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: AuthStyles.spacing8),
                  const Expanded(
                    child: Text(
                      'Se souvenir de moi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AuthStyles.spacing20),

          // Submit button
          AppButton(
            label: 'Se connecter',
            icon: Icons.login_rounded,
            loading: widget.loading,
            onPressed: _handleSubmit,
          ),

          // Error message
          if (widget.error != null) ...[
            const SizedBox(height: AuthStyles.spacing16),
            Container(
              padding: const EdgeInsets.all(AuthStyles.spacing12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: AuthStyles.spacing8),
                  Expanded(
                    child: Text(
                      widget.error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AuthStyles.spacing16),

          // Divider
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFE5E7EB))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AuthStyles.spacing12),
                child: Text(
                  'ou',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            ],
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Register button
          OutlinedButton(
            onPressed: widget.loading ? null : widget.onGoToRegister,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AuthStyles.spacing16),
              side: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AuthStyles.radiusMedium),
              ),
            ),
            child: const Text(
              'Créer un compte',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AuthStyles.primary,
              ),
            ),
          ),

          // Guest mode button
          if (widget.onSkip != null) ...[
            const SizedBox(height: AuthStyles.spacing12),
            TextButton(
              onPressed: widget.loading ? null : widget.onSkip,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AuthStyles.spacing12),
              ),
              child: Text(
                'Continuer sans compte',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.loading ? Colors.grey : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],

          // Debug info
          if (kDebugMode && widget.apiBaseUrl != null) ...[
            const SizedBox(height: AuthStyles.spacing12),
            Text(
              'API: ${widget.apiBaseUrl}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
