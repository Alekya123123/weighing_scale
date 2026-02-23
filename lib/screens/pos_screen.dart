// import 'package:flutter/material.dart';
// import 'weighing_scale_screen.dart';
//
// class PosScreen extends StatefulWidget {
//   @override
//   State<PosScreen> createState() => _PosScreenState();
// }
//
// class _PosScreenState extends State<PosScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('POS Screen')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//
//             TextField(decoration: InputDecoration(labelText: 'Product Name')),
//             SizedBox(height: 16),
//
//             // ADD THE SCALE BUTTON HERE
//             ElevatedButton(
//               onPressed: () =>
//                   Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) =>
//                     // WeighingScaleScreen()
//                 WeighingScaleScreen(productName: 'name', unitPrice:10,)
//                 // AutoWeightPriceDialog(productName: 'name ', unitPrice:10,)
//                 ),
//               ),
//               child: Text('Get Weight from Scale'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: Size(double.infinity, 50),
//               ),
//             ),
//
//             SizedBox(height: 16),
//             TextField(decoration: InputDecoration(labelText: 'Weight (auto)')),
//             // More POS widgets...
//           ],
//         ),
//       ),
//     );
//   }
// }

///////////


import 'package:flutter/material.dart';



class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String barcode = "";
  double weight = 0.0;
  double pricePerKg = 10.0;
  double totalPrice = 0.0;
  bool weightIsBarcode = false; // New flag

  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _addLog("POS system initialized.");
  }

  void _addLog(String message) {
    print(message);
    setState(() {
      logs.insert(0, "[${DateTime.now().toIso8601String()}] $message");
      if (logs.length > 20) logs.removeLast();
    });
  }

  void _onSubmitted(String value) {
    value = value.trim();
    _addLog("Received input: $value");

    try {
      String normalized = value.replaceAll(' ', '').toUpperCase();
      final weightPattern = RegExp(r'^W?(\d+([.,]\d+)?)KG?$');
      final match = weightPattern.firstMatch(normalized);

      if (match != null) {
        // Real weight input
        String weightStr = match.group(1)!.replaceAll(',', '.');
        final parsedWeight = double.tryParse(weightStr);

        if (parsedWeight != null) {
          setState(() {
            weight = parsedWeight;
            totalPrice = weight * pricePerKg;
            weightIsBarcode = false;
            barcode = ""; // clear barcode if previous
          });
          _addLog("Weight parsed: $weight kg, Total: $totalPrice");
        } else {
          _addLog("Error parsing weight: $value");
        }
      } else if (normalized.contains(',') || normalized.contains('.')) {
        // Decimal numeric → real weight
        final parsedWeight = double.tryParse(normalized.replaceAll(',', '.'));
        if (parsedWeight != null) {
          setState(() {
            weight = parsedWeight;
            totalPrice = weight * pricePerKg;
            weightIsBarcode = false;
            barcode = "";
          });
          _addLog("Weight parsed (decimal): $weight kg, Total: $totalPrice");
        }
      } else {
        // Pure numeric barcode → show in weight field
        setState(() {
          barcode = value;
          weight = double.tryParse(value) ?? 0;
          totalPrice = 0;
          weightIsBarcode = true;
        });
        _addLog("Barcode scanned (shown as weight): $barcode");
      }
    } catch (e, stackTrace) {
      _addLog("Exception: $e");
      _addLog("StackTrace: $stackTrace");
    }

    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cross-Platform POS - Magellan 9800i")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              onSubmitted: _onSubmitted,
              decoration: const InputDecoration(
                hintText: "Scan barcode / place item on scale",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Display barcode, weight, price
            Text("Barcode: $barcode", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(
              "Weight: $weight kg",
              style: TextStyle(
                fontSize: 20,
                color: weightIsBarcode ? Colors.grey : Colors.black,
                fontStyle: weightIsBarcode ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            Text("Price per Kg: $pricePerKg", style: const TextStyle(fontSize: 18)),
            Text(
              "Total Price: $totalPrice",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            const Divider(),

            const Text("Logs:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black12,
                child: ListView.builder(
                  reverse: true,
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Text(
                      logs[index],
                      style: const TextStyle(fontSize: 14),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
