import 'package:flutter/material.dart';
import '../data/services/ml_service.dart';
import '../data/services/nutrition_service.dart';
import '../data/models/food_model.dart';
import '../data/services/chat_service.dart';

class FoodProvider with ChangeNotifier {
  final MLService _mlService = MLService();
  final NutritionService _nutritionService = NutritionService();
  final ChatService _chatService = ChatService();
  String _chatResponse = "";
  bool _isChatLoading = false;

  String get chatResponse => _chatResponse;
  bool get isChatLoading => _isChatLoading;

  String _prediction = "Enter details to predict";
  FoodNutrition? _searchedFood;
  bool _isLoading = false;

  List<FoodNutrition> _recommendedFoods = [];
  List<FoodNutrition> _allFoods = [];

  // Getters
  String get prediction => _prediction;
  FoodNutrition? get searchedFood => _searchedFood;
  bool get isLoading => _isLoading;
  List<FoodNutrition> get recommendedFoods => _recommendedFoods;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _mlService.loadModel();

      _allFoods = await _nutritionService.fetchAllFoods();
      print("Success: Loaded ${_allFoods.length} foods from CSV.");
    } catch (e) {
      print("Initialization Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchFood(String query) async {
    _isLoading = true;
    notifyListeners();
    _searchedFood = await _nutritionService.fetchNutrition(query);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> askAI(String question) async {
    _isChatLoading = true;
    notifyListeners();

    _chatResponse = await _chatService.getNutritionAdvice(question);

    _isChatLoading = false;
    notifyListeners();
  }

  void predictAndRecommend(double c, double p, double cal, double f) {
    _prediction = _mlService.predict(c, p, cal, f);

    List<FoodNutrition> tempMatches = _allFoods.where((food) {
      bool calMatch = (food.calories - cal).abs() <= 100;
      bool proMatch = (food.protein - p).abs() <= 15;
      return calMatch && proMatch;
    }).toList();

    tempMatches.sort((a, b) {
      double diffA = (a.calories - cal).abs() + (a.protein - p).abs();
      double diffB = (b.calories - cal).abs() + (b.protein - p).abs();
      return diffA.compareTo(diffB);
    });

    _recommendedFoods = tempMatches.length > 5
        ? tempMatches.sublist(0, 5)
        : tempMatches;

    print("Recommended Count: ${_recommendedFoods.length}");
    notifyListeners();
  }

  // Dashboard Summary Logic
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  double get totalCalories => _totalCalories;
  double get totalProtein => _totalProtein;
  double get totalCarbs => _totalCarbs;
  double get totalFat => _totalFat;

  void addToDailyLog(FoodNutrition food) {
    _totalCalories += food.calories;
    _totalProtein += food.protein;
    _totalCarbs += food.carbs;
    _totalFat += food.fat;
    notifyListeners();
  }

  void resetDailyLog() {
    _totalCalories = 0;
    _totalProtein = 0;
    _totalCarbs = 0;
    _totalFat = 0;
    _recommendedFoods = [];
    _searchedFood = null;
    _prediction = "Enter details to predict";
    notifyListeners();
  }
}
