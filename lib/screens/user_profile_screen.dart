import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';
import 'package:lottie/lottie.dart';

class UserProfileScreen extends StatelessWidget {
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Profile"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: _height,
                decoration: const InputDecoration(
                  labelText: "Height (cm)",
                  prefixIcon: Icon(Icons.height),
                ),
              ),
              TextField(
                controller: _weight,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  prefixIcon: Icon(Icons.fitness_center),
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    double w = double.tryParse(_weight.text) ?? 0;
                    double h = (double.tryParse(_height.text) ?? 0) / 100;
                    double bmi = (h > 0) ? w / (h * h) : 0;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MainNavigationScreen(bmi: bmi, name: _name.text),
                      ),
                    );
                  },
                  child: const Text("Save & Continue"),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Lottie.asset(
                  'assets/animation/Nutrition.json',
                  width: 800,
                  height: 300,
                  repeat: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
