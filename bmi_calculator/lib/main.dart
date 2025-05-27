import 'package:flutter/material.dart';

void main() {
  runApp(BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BMIScreen(),
    );
  }
}

class BMIScreen extends StatefulWidget {
  @override
  _BMIScreenState createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  double? bmi;
  String category = '';

  void calculateBMI() {
    final heightText = heightController.text;
    final weightText = weightController.text;

    if (heightText.isEmpty || weightText.isEmpty) return;

    final double? height = double.tryParse(heightText);
    final double? weight = double.tryParse(weightText);

    if (height == null || weight == null || height <= 0 || weight <= 0) return;

    final double heightInMeters = height / 100;
    final double result = weight / (heightInMeters * heightInMeters);

    setState(() {
      bmi = result;
      category = getBMICategory(result);
    });
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5)
      return "Underweight";
    else if (bmi < 24.9)
      return "Normal weight";
    else if (bmi < 29.9)
      return "Overweight";
    else
      return "Obese";
  }

  void resetFields() {
    heightController.clear();
    weightController.clear();
    setState(() {
      bmi = null;
      category = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BMI Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: calculateBMI,
                    child: Text('Calculate'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 30),
            if (bmi != null) ...[
              Text(
                'Your BMI: ${bmi!.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Category: $category',
                style: TextStyle(fontSize: 20, color: Colors.blueAccent),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
