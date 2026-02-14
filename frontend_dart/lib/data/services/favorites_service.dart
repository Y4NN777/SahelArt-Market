import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorites';
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  SharedPreferences? _prefs;
  Set<String> _favorites = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _favorites = (_prefs!.getStringList(_key) ?? []).toSet();
  }

  Set<String> get favorites => Set.unmodifiable(_favorites);

  bool isFavorite(String productId) => _favorites.contains(productId);

  Future<void> toggleFavorite(String productId) async {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    await _prefs!.setStringList(_key, _favorites.toList());
  }

  Future<void> addFavorite(String productId) async {
    if (!_favorites.contains(productId)) {
      _favorites.add(productId);
      await _prefs!.setStringList(_key, _favorites.toList());
    }
  }

  Future<void> removeFavorite(String productId) async {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
      await _prefs!.setStringList(_key, _favorites.toList());
    }
  }

  int get count => _favorites.length;
}
