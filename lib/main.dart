import 'package:flutter/material.dart';
import 'package:perplexweighing/screens/weighing_scale_screen.dart';
import 'screens/pos_screen.dart'; // Point to your POS screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS App',
      debugShowCheckedModeBanner: false,
      home:
      // PosScreen(),
      WeighingScaleScreen(productName: 'Onion', unitPrice:10,)


    );
  }
}
