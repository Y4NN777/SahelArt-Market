import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../presentation/widgets/common/app_button.dart';
import '../styles/auth_styles.dart';
import '../widgets/auth_background_hero.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_input_field.dart';

/// Customer registration page - Simple one-step form
class CustomerRegisterPage extends StatefulWidget {
  const CustomerRegisterPage({
    super.key,
    required this.onRegister,
    required this.onBack,
    required this.loading,
    this.error,
  });

  final Future<void> Function({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) onRegister;
  final VoidCallback onBack;
  final bool loading;
  final String? error;

  @override
  State<CustomerRegisterPage> createState() => _CustomerRegisterPageState();
}

class _CustomerRegisterPageState extends State<CustomerRegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    await widget.onRegister(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: AuthStyles.warmTaupe,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackgroundHero(
            backgroundImage: 'assets/branding/login_overlay_background.png',
            overlayOpacity: 0.2,
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AuthStyles.spacing16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.loading ? null : widget.onBack,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        tooltip: 'Retour',
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isMobile
                      ? _buildMobileLayout()
                      : _buildDesktopLayout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFDFBF7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuthStyles.spacing24),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthStyles.spacing24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AuthGlassCard(
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: AuthStyles.primary, size: 28),
              const SizedBox(width: AuthStyles.spacing12),
              const Expanded(
                child: Text(
                  'Compte Client',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AuthStyles.spacing8),
          const Text(
            'Créez votre compte pour acheter',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: AuthStyles.spacing24),

          // First name & Last name
          Row(
            children: [
              Expanded(
                child: AuthInputField(
                  controller: _firstNameCtrl,
                  focusNode: _firstNameFocus,
                  label: 'Prénom',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _lastNameFocus.requestFocus(),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Prénom requis' : null,
                  enabled: !widget.loading,
                ),
              ),
              const SizedBox(width: AuthStyles.spacing12),
              Expanded(
                child: AuthInputField(
                  controller: _lastNameCtrl,
                  focusNode: _lastNameFocus,
                  label: 'Nom',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Nom requis' : null,
                  enabled: !widget.loading,
                ),
              ),
            ],
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Email
          AuthInputField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            label: 'Email',
            hint: 'votre@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            validator: EmailValidator.validate,
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Password
          AuthInputField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            label: 'Mot de passe',
            hint: 'Minimum 8 caractères',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
            validator: (v) => PasswordValidator.validate(v),
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Confirm password
          AuthInputField(
            controller: _confirmCtrl,
            focusNode: _confirmFocus,
            label: 'Confirmer le mot de passe',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            showPasswordToggle: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Confirmation requise';
              if (v != _passwordCtrl.text) return 'Mots de passe différents';
              return null;
            },
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing24),

          // Submit button
          AppButton(
            label: 'Créer mon compte',
            icon: Icons.person_add_alt_1_rounded,
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
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
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
        ],
      ),
    );
  }
}
