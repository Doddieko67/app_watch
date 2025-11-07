import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/nutrition/domain/entities/food_analysis_result.dart';

/// Base de datos local de alimentos (nutrition_database.json)
///
/// Contiene ~500 alimentos con valores nutricionales
/// Implementa búsqueda fuzzy con algoritmo de Levenshtein
class LocalNutritionDatabase {
  List<LocalFoodItem>? _foods;
  bool _isLoaded = false;

  /// Carga la base de datos desde assets
  Future<void> load() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/nutrition_database.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final foodsList = json['foods'] as List;

      _foods = foodsList
          .map((e) => LocalFoodItem.fromJson(e as Map<String, dynamic>))
          .toList();

      _isLoaded = true;
    } catch (e) {
      print('Error loading nutrition database: $e');
      _foods = [];
    }
  }

  /// Busca un alimento por query con fuzzy matching
  Future<FoodData?> searchFood(String query) async {
    if (!_isLoaded) await load();
    if (_foods == null || _foods!.isEmpty) return null;

    final normalized = _normalizeQuery(query);

    // 1. Búsqueda exacta en nombre
    for (final food in _foods!) {
      if (food.name.toLowerCase() == normalized) {
        return _foodItemToFoodData(food, 100);
      }
    }

    // 2. Búsqueda exacta en aliases
    for (final food in _foods!) {
      if (food.aliases.any((alias) => alias.toLowerCase() == normalized)) {
        return _foodItemToFoodData(food, 100);
      }
    }

    // 3. Búsqueda fuzzy (Levenshtein distance)
    LocalFoodItem? bestMatch;
    int bestDistance = 999;

    for (final food in _foods!) {
      // Buscar en nombre
      final distance = _levenshteinDistance(normalized, food.name.toLowerCase());
      if (distance < bestDistance && distance <= 3) {
        bestDistance = distance;
        bestMatch = food;
      }

      // Buscar en aliases
      for (final alias in food.aliases) {
        final aliasDistance = _levenshteinDistance(
          normalized,
          alias.toLowerCase(),
        );
        if (aliasDistance < bestDistance && aliasDistance <= 3) {
          bestDistance = aliasDistance;
          bestMatch = food;
        }
      }
    }

    if (bestMatch != null) {
      return _foodItemToFoodData(bestMatch, 100);
    }

    return null;
  }

  /// Convierte LocalFoodItem a FoodData
  FoodData _foodItemToFoodData(LocalFoodItem item, double quantity) {
    final factor = quantity / 100; // Los valores son por 100g

    return FoodData(
      name: item.name,
      quantity: quantity,
      unit: 'g',
      calories: item.caloriesPer100g * factor,
      protein: item.proteinPer100g * factor,
      carbs: item.carbsPer100g * factor,
      fats: item.fatsPer100g * factor,
    );
  }

  /// Normaliza query
  String _normalizeQuery(String query) {
    return query
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'\d+g?'), '') // Remover cantidades
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  /// Algoritmo de Levenshtein para distancia entre strings
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }

    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Obtiene todos los alimentos (para búsqueda avanzada)
  List<LocalFoodItem> get allFoods => _foods ?? [];

  /// Verifica si está cargada
  bool get isLoaded => _isLoaded;
}

/// Item de la base de datos local
class LocalFoodItem {
  final String id;
  final String name;
  final List<String> aliases;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final String category;

  LocalFoodItem({
    required this.id,
    required this.name,
    required this.aliases,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    required this.category,
  });

  factory LocalFoodItem.fromJson(Map<String, dynamic> json) {
    return LocalFoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      aliases: (json['aliases'] as List).cast<String>(),
      caloriesPer100g: (json['calories_per_100g'] as num).toDouble(),
      proteinPer100g: (json['protein_per_100g'] as num).toDouble(),
      carbsPer100g: (json['carbs_per_100g'] as num).toDouble(),
      fatsPer100g: (json['fats_per_100g'] as num).toDouble(),
      category: json['category'] as String,
    );
  }
}
