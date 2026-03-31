import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/food_model.dart';

class NutritionService {
  Interpreter? _interpreter;
  Map<String, dynamic>? _tokenizer;

  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/food_nutrition_model.tflite',
      );

      final String jsonString = await rootBundle.loadString(
        'assets/food_tokenizer.json',
      );
      _tokenizer = jsonDecode(jsonString);

      print("ANN Model and Tokenizer Loaded Successfully!");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<FoodNutrition?> fetchNutrition(String query) async {
    if (_interpreter == null || _tokenizer == null) {
      await initModel();
    }

    try {
      List<String> words = query.toLowerCase().trim().split(' ');

      List<int> tokens = words.map((w) {
        return (_tokenizer![w] as num? ?? 0).toInt();
      }).toList();

      List<int> input = List.filled(10, 0);
      for (int i = 0; i < tokens.length && i < 10; i++) {
        input[i] = tokens[i];
      }

      var inputBuffer = [input];
      var outputBuffer = List.filled(4, 0.0).reshape([1, 4]);

      _interpreter!.run(inputBuffer, outputBuffer);

      final results = outputBuffer[0];

      return FoodNutrition(
        name: query.toUpperCase(),
        calories: double.parse(results[0].toStringAsFixed(0)),
        protein: double.parse(results[1].toStringAsFixed(1)),
        carbs: double.parse(results[2].toStringAsFixed(1)),
        fat: double.parse(results[3].toStringAsFixed(1)),
      );
    } catch (e) {
      print("Prediction Error: $e");
      return null;
    }
  }

  Future<List<FoodNutrition>> fetchAllFoods() async {
    try {
      final String csvData = await rootBundle.loadString(
        'assets/cleaned_nutrition_dataset_per100g.csv',
      );
      List<String> lines = csvData.split('\n');
      List<FoodNutrition> foodList = [];

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        List<String> values = lines[i].split(',');

        foodList.add(
          FoodNutrition(
            name: values[5].trim(), // food column
            calories: double.tryParse(values[7]) ?? 0.0,
            protein: double.tryParse(values[11]) ?? 0.0,
            carbs: double.tryParse(values[4]) ?? 0.0,
            fat: double.tryParse(values[10]) ?? 0.0,
          ),
        );
      }
      return foodList;
    } catch (e) {
      print("CSV Loading Error: $e");
      return [];
    }
  }
}
