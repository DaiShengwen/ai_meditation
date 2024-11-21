import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/meditation_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MeditationService(),
      child: MaterialApp(
        title: '正念冥想',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
