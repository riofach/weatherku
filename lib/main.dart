import 'package:flutter/material.dart';
import 'ui/home_page.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherKu',
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
