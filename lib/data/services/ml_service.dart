import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class MLService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/food_model.tflite');
    final labelStr = await rootBundle.loadString('assets/labels.txt');
    _labels = labelStr.split('\n').where((s) => s.isNotEmpty).toList();
  }

  String predict(double carbs, double protein, double calories, double fat) {
    if (_interpreter == null) return "Model not loaded";

    var input = [
      [carbs, protein, calories, fat],
    ];
    var output = List.filled(1 * 11, 0.0).reshape([1, 11]);
    _interpreter!.run(input, output);

    double maxProb = -1.0;
    int maxIndex = -1;
    for (int i = 0; i < 11; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        maxIndex = i;
      }
    }
    return _labels![maxIndex];
  }
}
