import 'package:flutter/material.dart';
import 'styles/auth_styles.dart';
import 'widgets/auth_background_hero.dart';
import 'widgets/auth_glass_card.dart';
import 'widgets/login_form_content.dart';
import 'widgets/mobile_auth_sheet.dart';
import 'widgets/mobile_hero_header.dart';

/// Modern login page with responsive design
/// Supports both mobile (bottom sheet) and desktop (centered card) layouts
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.loading,
    required this.error,
    required this.onLogin,
    required this.apiBaseUrl,
    required this.onGoToRegister,
    this.rememberMeInitial = false,
    this.onSkip,
  });

  final bool loading;
  final String? error;
  final String apiBaseUrl;
  final bool rememberMeInitial;
  final VoidCallback onGoToRegister;
  final VoidCallback? onSkip;
  final Future<void> Function(String email, String password, bool rememberMe) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _sheetExpanded = false;

  void _toggleSheet(bool expand) {
    if (mounted) {
      FocusScope.of(context).unfocus();
      setState(() => _sheetExpanded = expand);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthStyles.warmTaupe,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AuthStyles.breakpointDesktop;
          return isDesktop ? _buildDesktopLayout() : _buildMobileLayout(constraints);
        },
      ),
    );
  }

  /// Desktop layout with centered glass card
  Widget _buildDesktopLayout() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const AuthBackgroundHero(
          backgroundImage: 'assets/branding/login_overlay_background.png',
          overlayOpacity: 0.3,
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AuthStyles.spacing40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AuthStyles.maxCardWidth,
              ),
              child: AuthGlassCard(
                child: LoginFormContent(
                  onSubmit: widget.onLogin,
                  onGoToRegister: widget.onGoToRegister,
                  onSkip: widget.onSkip,
                  loading: widget.loading,
                  error: widget.error,
                  apiBaseUrl: widget.apiBaseUrl,
                  rememberMeInitial: widget.rememberMeInitial,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile layout with hero header and animated bottom sheet
  Widget _buildMobileLayout(BoxConstraints constraints) {
    final maxSheetHeight = constraints.maxHeight * 0.85;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background with hero content
        const AuthBackgroundHero(
          backgroundImage: 'assets/branding/login_overlay_background.png',
          overlayOpacity: 0.3,
        ),

        // Hero header (visible when sheet is collapsed)
        if (!_sheetExpanded)
          const SafeArea(
            child: MobileHeroHeader(),
          ),

        // Backdrop tap to close when expanded
        if (_sheetExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _toggleSheet(false),
              child: Container(color: Colors.transparent),
            ),
          ),

        // Animated bottom sheet
        MobileAuthSheet(
          isExpanded: _sheetExpanded,
          onToggle: () => _toggleSheet(!_sheetExpanded),
          maxHeight: maxSheetHeight,
          collapsedHeight: 360,
          child: _sheetExpanded
              ? _buildExpandedSheetContent()
              : _buildCollapsedSheetContent(),
        ),
      ],
    );
  }

  Widget _buildCollapsedSheetContent() {
    return CollapsedSheetContent(
      onExpand: () => _toggleSheet(true),
    );
  }

  Widget _buildExpandedSheetContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AuthStyles.spacing24,
        AuthStyles.spacing8,
        AuthStyles.spacing24,
        AuthStyles.spacing24,
      ),
      child: LoginFormContent(
        onSubmit: widget.onLogin,
        onGoToRegister: widget.onGoToRegister,
        onSkip: widget.onSkip,
        loading: widget.loading,
        error: widget.error,
        apiBaseUrl: widget.apiBaseUrl,
        showClose: true,
        onClose: () => _toggleSheet(false),
        rememberMeInitial: widget.rememberMeInitial,
      ),
    );
  }
}
