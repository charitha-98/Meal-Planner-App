import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'user_profile_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _data = [
    {
      "title": "Track Nutrition",
      "desc": "Identify nutrients using AI based on your diet.",
      "icon": Icons.psychology,
    },
    {
      "title": "Healthy BMI",
      "desc": "Keep track of your body mass index effectively.",
      "icon": Icons.monitor_weight,
    },
    {
      "title": "Daily Goals",
      "desc": "Achieve your fitness targets every single day.",
      "icon": Icons.track_changes,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Lottie.asset(
              'assets/animation/welcom_bg.json',
              width: 120,
              repeat: true,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Lottie.asset(
              'assets/animation/welcom_bg.json',
              width: 180,
              repeat: true,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Lottie.asset(
              'assets/animation/welcom_bg.json',
              width: 190,
              repeat: true,
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(color: Colors.white.withOpacity(0.85)),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _data.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, i) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _data[i]['icon'],
                          size: 100,
                          color: Colors.green[800],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _data[i]['title'],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _data[i]['desc'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // 4. Dot Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    activeDotColor: Colors.green[700]!,
                    dotColor: Colors.grey.shade400,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 16,
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 5,
            right: 10,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _currentPage == 2 ? 1.0 : 0.0,
              child: _currentPage == 2
                  ? TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileScreen(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
