import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_planner/providers/food_provider.dart';

class SearchScreen extends StatelessWidget {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Global Nutrition Search"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search (e.g. Milk, Oats, Rice)",
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onSubmitted: (val) => foodProvider.searchFood(val),
              ),
            ),
            SizedBox(height: 25),
            if (foodProvider.isLoading)
              CircularProgressIndicator(color: Colors.green),
            if (foodProvider.searchedFood != null)
              _buildNutritionInfo(foodProvider.searchedFood!, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(dynamic food, BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);

    return Expanded(
      child: ListView(
        children: [
          Text(
            food.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "(Nutritional value per 100g)",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          _infoTile(
            "Calories",
            "${food.calories} kcal",
            Icons.bolt,
            Colors.orange,
          ),
          _infoTile(
            "Proteins",
            "${food.protein} g",
            Icons.fitness_center,
            Colors.blue,
          ),
          _infoTile("Carbs", "${food.carbs} g", Icons.grain, Colors.brown),
          _infoTile("Fats", "${food.fat} g", Icons.water_drop, Colors.red),

          SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: Icon(Icons.add_circle_outline),
            label: Text(
              "Add to Today's Diary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (foodProvider.searchedFood != null) {
                try {
                  foodProvider.addToDailyLog(foodProvider.searchedFood!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${foodProvider.searchedFood!.name} added successfully!",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  _searchController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("This food is already in your daily log!"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
