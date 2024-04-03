import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

// cette classe représente l'application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // la page d'accueil de l'application
      home: HomePage(title: 'Portfolio Management'),
    );
  }
}
