import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../presentation/widgets/common/app_button.dart';
import '../styles/auth_styles.dart';
import '../widgets/auth_background_hero.dart';
import '../widgets/auth_glass_card.dart';
import '../widgets/auth_input_field.dart';

/// Vendor registration page - 2-step stepper form
class VendorRegisterPage extends StatefulWidget {
  const VendorRegisterPage({
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
    required String businessName,
    required String businessDescription,
    required String phone,
  }) onRegister;
  final VoidCallback onBack;
  final bool loading;
  final String? error;

  @override
  State<VendorRegisterPage> createState() => _VendorRegisterPageState();
}

class _VendorRegisterPageState extends State<VendorRegisterPage> {
  int _currentStep = 0;

  // Step 1: Personal info
  final GlobalKey<FormState> _personalFormKey = GlobalKey<FormState>();
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

  // Step 2: Business info
  final GlobalKey<FormState> _businessFormKey = GlobalKey<FormState>();
  final TextEditingController _businessNameCtrl = TextEditingController();
  final TextEditingController _businessDescCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  final FocusNode _businessNameFocus = FocusNode();
  final FocusNode _businessDescFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _businessNameCtrl.dispose();
    _businessDescCtrl.dispose();
    _phoneCtrl.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _businessNameFocus.dispose();
    _businessDescFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (_personalFormKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_businessFormKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    await widget.onRegister(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      businessName: _businessNameCtrl.text.trim(),
      businessDescription: _businessDescCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
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
                        onPressed: widget.loading
                            ? null
                            : (_currentStep == 0 ? widget.onBack : _goToPreviousStep),
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
          maxHeight: MediaQuery.of(context).size.height * 0.88,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AuthStyles.spacing24),
              _buildStepper(),
              const SizedBox(height: AuthStyles.spacing24),
              _buildCurrentStepForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AuthStyles.spacing24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AuthGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: AuthStyles.spacing24),
                _buildStepper(),
                const SizedBox(height: AuthStyles.spacing24),
                _buildCurrentStepForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.storefront_outlined, color: AuthStyles.primary, size: 28),
            const SizedBox(width: AuthStyles.spacing12),
            const Expanded(
              child: Text(
                'Compte Artisan',
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
          'Créez votre boutique en ligne',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepIndicator(0, 'Informations\npersonnelles'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 1
                ? AuthStyles.primary
                : const Color(0xFFE5E7EB),
          ),
        ),
        _buildStepIndicator(1, 'Informations\nbusiness'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AuthStyles.primary : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AuthStyles.primary, width: 3)
                : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
        const SizedBox(height: AuthStyles.spacing8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? const Color(0xFF1F2937)
                  : const Color(0xFF9CA3AF),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepForm() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoForm();
      case 1:
        return _buildBusinessInfoForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            onFieldSubmitted: (_) => _goToNextStep(),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Confirmation requise';
              if (v != _passwordCtrl.text) return 'Mots de passe différents';
              return null;
            },
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing24),

          // Next button
          AppButton(
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            onPressed: _goToNextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoForm() {
    return Form(
      key: _businessFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Business name
          AuthInputField(
            controller: _businessNameCtrl,
            focusNode: _businessNameFocus,
            label: 'Nom de votre boutique',
            hint: 'Ex: Artisanat Sahélien',
            prefixIcon: Icons.store_outlined,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _businessDescFocus.requestFocus(),
            validator: (v) => (v?.trim().isEmpty ?? true)
                ? 'Nom de boutique requis'
                : null,
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Business description
          TextFormField(
            controller: _businessDescCtrl,
            focusNode: _businessDescFocus,
            maxLines: 3,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              labelText: 'Description de votre activité',
              hintText: 'Décrivez votre savoir-faire artisanal...',
              labelStyle: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.description_outlined,
                color: Color(0xFF6B7280),
              ),
              alignLabelWithHint: true,
            ),
            validator: (v) => (v?.trim().isEmpty ?? true)
                ? 'Description requise'
                : (v!.length < 20 ? 'Minimum 20 caractères' : null),
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing16),

          // Phone
          AuthInputField(
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            label: 'Téléphone',
            hint: '+226 XX XX XX XX',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(),
            validator: (v) {
              if (v?.trim().isEmpty ?? true) return 'Téléphone requis';
              if (v!.length < 8) return 'Numéro invalide';
              return null;
            },
            enabled: !widget.loading,
          ),

          const SizedBox(height: AuthStyles.spacing24),

          // Submit button
          AppButton(
            label: 'Créer ma boutique',
            icon: Icons.check_rounded,
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
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.danger, size: 20),
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
