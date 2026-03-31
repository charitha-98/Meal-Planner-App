class FoodNutrition {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodNutrition({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodNutrition.fromJson(Map<String, dynamic> json, String query) {
    return FoodNutrition(
      name: json['name']?.toString().toUpperCase() ?? query.toUpperCase(),
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbohydrates_total_g'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat_total_g'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
