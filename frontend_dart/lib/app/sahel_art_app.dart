import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/pages/role_selection_page.dart';
import '../features/auth/presentation/pages/customer_register_page.dart';
import '../features/auth/presentation/pages/vendor_register_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/cart/domain/cart_item.dart';
import '../features/products/domain/product.dart';
import '../features/products/presentation/home_page.dart';
import '../data/services/storage_service.dart';

enum AuthView { login, roleSelection, customerRegister, vendorRegister }

class SahelArtApp extends StatefulWidget {
  const SahelArtApp({super.key});

  @override
  State<SahelArtApp> createState() => _SahelArtAppState();
}

class _SahelArtAppState extends State<SahelArtApp> {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();
  final List<CartItem> _cart = [];

  String? _token;
  bool _booting = true;
  bool _introDone = false;
  bool _authLoading = false;
  bool _rememberMe = false;
  String? _authError;
  AuthView _authView = AuthView.login;

  @override
  void initState() {
    super.initState();
    _startIntro();
    _bootstrapAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SahelArt Market',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_introDone || _booting) {
      return SplashPage(
        loadingLabel: _booting ? 'Préparation de votre espace...' : 'Bienvenue',
      );
    }

    if (_token == null) {
      // Role selection screen
      if (_authView == AuthView.roleSelection) {
        return RoleSelectionPage(
          onRoleSelected: (role) {
            setState(() {
              _authView = role == 'customer'
                  ? AuthView.customerRegister
                  : AuthView.vendorRegister;
              _authError = null;
            });
          },
          onBackToLogin: () {
            setState(() {
              _authView = AuthView.login;
              _authError = null;
            });
          },
        );
      }

      // Customer register screen
      if (_authView == AuthView.customerRegister) {
        return CustomerRegisterPage(
          loading: _authLoading,
          error: _authError,
          onRegister: ({
            required String firstName,
            required String lastName,
            required String email,
            required String password,
          }) async {
            // TODO: Implement customer registration
            setState(() => _authLoading = true);
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              _authLoading = false;
              _authError = 'Inscription customer pas encore implémentée';
            });
          },
          onBack: () {
            setState(() {
              _authView = AuthView.roleSelection;
              _authError = null;
            });
          },
        );
      }

      // Vendor register screen
      if (_authView == AuthView.vendorRegister) {
        return VendorRegisterPage(
          loading: _authLoading,
          error: _authError,
          onRegister: ({
            required String firstName,
            required String lastName,
            required String email,
            required String password,
            required String businessName,
            required String businessDescription,
            required String phone,
          }) async {
            // TODO: Implement vendor registration
            setState(() => _authLoading = true);
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              _authLoading = false;
              _authError = 'Inscription vendor pas encore implémentée';
            });
          },
          onBack: () {
            setState(() {
              _authView = AuthView.roleSelection;
              _authError = null;
            });
          },
        );
      }

      // Login screen (default)
      return LoginPage(
        loading: _authLoading,
        error: _authError,
        apiBaseUrl: _apiClient.baseUrl,
        rememberMeInitial: _rememberMe,
        onGoToRegister: () {
          setState(() {
            _authView = AuthView.roleSelection;
            _authError = null;
          });
        },
        onLogin: _handleLogin,
      );
    }

    return HomePage(
      apiClient: _apiClient.withToken(_token!),
      cart: _cart,
      onLogout: _handleLogout,
      onAddToCart: _handleAddToCart,
      onUpdateQuantity: _handleUpdateQuantity,
      onCheckout: _handleCheckout,
    );
  }

  Future<void> _startIntro() async {
    await Future<void>.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;
    setState(() {
      _introDone = true;
    });
  }

  Future<void> _bootstrapAuth() async {
    final remember = await _storageService.getRememberMe();
    final token = await _storageService.getToken();

    if (!mounted) return;

    if (remember && token != null && token.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _token = token;
        _booting = false;
      });
      return;
    }

    await _storageService.clearToken();
    if (!remember) {
      await _storageService.clearRememberMe();
    }

    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      _token = null;
      _booting = false;
    });
  }

  Future<void> _handleLogin(String email, String password, bool rememberMe) async {
    setState(() {
      _authLoading = true;
      _authError = null;
    });

    try {
      final token = await _apiClient.login(email: email, password: password);
      await _storageService.saveRememberMe(rememberMe);
      if (rememberMe) {
        await _storageService.saveToken(token);
      } else {
        await _storageService.clearToken();
      }

      if (!mounted) return;
      setState(() {
        _token = token;
        _rememberMe = rememberMe;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _authLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _storageService.clearToken();
    await _storageService.clearRememberMe();

    if (!mounted) return;
    setState(() {
      _token = null;
      _rememberMe = false;
      _cart.clear();
      _authError = null;
      _authView = AuthView.login;
    });
  }

  void _handleAddToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void _handleUpdateQuantity(Product product, int quantity) {
    setState(() {
      _cart.removeWhere((item) => item.product.id == product.id);
      if (quantity > 0) {
        _cart.add(CartItem(product: product, quantity: quantity));
      }
    });
  }

  Future<String> _handleCheckout() async {
    if (_token == null) {
      throw Exception('Session invalide.');
    }
    if (_cart.isEmpty) {
      throw Exception('Le panier est vide.');
    }

    final authedClient = _apiClient.withToken(_token!);
    final order = await authedClient.createOrder(_cart);
    await authedClient.payOrder(orderId: order.id, amount: order.total, method: 'orange_money');

    setState(() {
      _cart.clear();
    });

    return order.id;
  }
}
