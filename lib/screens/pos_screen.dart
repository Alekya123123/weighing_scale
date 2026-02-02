import 'package:flutter/material.dart';
import 'weighing_scale_screen.dart'; // Adjust path if needed

class PosScreen extends StatefulWidget {
  @override
  State<PosScreen> createState() => _PosScreenState(); // REQUIRED
}

class _PosScreenState extends State<PosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('POS Screen')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Your existing POS fields
            TextField(decoration: InputDecoration(labelText: 'Product Name')),
            SizedBox(height: 16),

            // ADD THE SCALE BUTTON HERE
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeighingScaleScreen()),
              ),
              child: Text('Get Weight from Scale'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),

            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Weight (auto)')),
            // More POS widgets...
          ],
        ),
      ),
    );
  }
}
