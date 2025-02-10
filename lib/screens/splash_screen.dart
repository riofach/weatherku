import 'package:flutter/material.dart';
import '../ui/home_page.dart';
import 'package:weather_kita/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Constants constants = Constants();

  @override
  void initState() {
    super.initState();

    // Inisialisasi animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Durasi animasi
    );

    // Animasi fade in dan fade out
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Efek easing
      ),
    );

    // Mulai animasi
    _controller.forward();

    // Setelah animasi selesai, navigasi ke HomePage
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Hapus controller saat widget di-dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3350),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/logo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
