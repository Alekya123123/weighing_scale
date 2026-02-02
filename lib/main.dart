import 'package:flutter/material.dart';
import 'screens/pos_screen.dart'; // Point to your POS screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS App',
      home: PosScreen(), // Your main POS screen
    );
  }
}
