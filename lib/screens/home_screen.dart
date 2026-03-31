import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_planner/providers/food_provider.dart';
import 'search_screen.dart';
import 'package:meal_planner/widgets/daily_chart.dart';

class HomeScreen extends StatelessWidget {
  final _carbs = TextEditingController();
  final _protein = TextEditingController();
  final _calories = TextEditingController();
  final _fat = TextEditingController();

  final double? bmi;
  final String? name;
  HomeScreen({Key? key, this.bmi, this.name}) : super(key: key);

  void _handlePrediction(BuildContext context, FoodProvider provider) {
    if (_carbs.text.isEmpty ||
        _protein.text.isEmpty ||
        _calories.text.isEmpty ||
        _fat.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all the fields before predicting!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    provider.predictAndRecommend(
      double.tryParse(_carbs.text) ?? 0,
      double.tryParse(_protein.text) ?? 0,
      double.tryParse(_calories.text) ?? 0,
      double.tryParse(_fat.text) ?? 0,
    );

    _carbs.clear();
    _protein.clear();
    _calories.clear();
    _fat.clear();
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Meal AI Predictor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SearchScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBMICard(bmi ?? 0.0, name ?? "User"),
            _buildDailySummary(foodProvider),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                "Predict & Find Matches",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPredictCard(context, foodProvider),

            _buildResultCard(foodProvider.prediction),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                "Top Recommended Foods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildRecommendationList(foodProvider),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationList(FoodProvider provider) {
    if (provider.recommendedFoods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Text(
          "No recommendations found yet.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.recommendedFoods.length,
      itemBuilder: (context, index) {
        final food = provider.recommendedFoods[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.restaurant, color: Colors.white, size: 20),
            ),
            title: Text(
              food.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Cal: ${food.calories.toStringAsFixed(0)} | Protein: ${food.protein}g",
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () {
                provider.addToDailyLog(food);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${food.name} added to your daily log!"),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Center(
        child: Icon(Icons.analytics_outlined, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildDailySummary(FoodProvider provider) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}/${now.month}/${now.year}";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nutritional Balance",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.resetDailyLog(),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: buildPieChart(
                      provider.totalProtein,
                      provider.totalCarbs,
                      provider.totalFat,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statIndicator(
                          "Protein",
                          const Color.fromARGB(255, 208, 211, 15),
                        ),
                        _statIndicator(
                          "Carbs",
                          const Color.fromARGB(255, 199, 8, 8),
                        ),
                        _statIndicator("Fat", Colors.redAccent),
                        const SizedBox(height: 20),
                        Text(
                          "${provider.totalCalories.toStringAsFixed(0)} kcal",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statIndicator(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPredictCard(BuildContext context, FoodProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _input(_carbs, "Carbohydrates (g)", Icons.grain),
              _input(_protein, "Protein (g)", Icons.fitness_center),
              _input(_calories, "Energy (kcal)", Icons.bolt),
              _input(_fat, "Fat (g)", Icons.water_drop),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePrediction(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Predict & Recommend"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String l, IconData i) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(i, color: Colors.green),
        labelText: l,
      ),
    );
  }

  Widget _buildResultCard(String res) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          res,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBMICard(double bmi, String name) {
    String status;
    Color statusColor;

    if (bmi < 18.5) {
      status = "Underweight";
      statusColor = Colors.orange;
    } else if (bmi < 25) {
      status = "Normal";
      statusColor = Colors.green;
    } else if (bmi < 30) {
      status = "Overweight";
      statusColor = Colors.orangeAccent;
    } else {
      status = "Obese";
      statusColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Center(
              child: Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $name!",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text(
                      "Condition: ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
