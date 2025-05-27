import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() {
  runApp(MMASApp());
}

class MMASApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMAS: Money Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MoneyTracker(),
    );
  }
}

class MoneyTracker extends StatefulWidget {
  @override
  _MoneyTrackerState createState() => _MoneyTrackerState();
}

class _MoneyTrackerState extends State<MoneyTracker> {
  Database? db;
  List<Map<String, dynamic>> transactions = [];

  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String selectedType = 'Expense';

  @override
  void initState() {
    super.initState();
    initializeDb();
  }

  Future<void> initializeDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'moneytracker.db');

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database database, int version) async {
        await database.execute(
          'CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, amount REAL, type TEXT)',
        );
      },
    );
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    if (db != null) {
      final List<Map<String, dynamic>> list =
          await db!.query('transactions', orderBy: 'id DESC');
      setState(() {
        transactions = list;
      });
    }
  }

  Future<void> addTransaction() async {
    String desc = descController.text.trim();
    String amountText = amountController.text.trim();

    if (desc.isEmpty || amountText.isEmpty) return;

    double? amount = double.tryParse(amountText);
    if (amount == null) return;

    await db!.insert('transactions', {
      'description': desc,
      'amount': amount,
      'type': selectedType,
    });

    descController.clear();
    amountController.clear();
    await loadTransactions();
  }

  double getBalance() {
    double total = 0;
    for (var tx in transactions) {
      double amount = tx['amount'];
      if (tx['type'] == 'Income') {
        total += amount;
      } else {
        total -= amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MMAS: Money Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Balance: ₹${getBalance().toStringAsFixed(2)}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            Row(
              children: [
                Text('Type:'),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedType,
                  items: ['Expense', 'Income']
                      .map((e) => DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: addTransaction,
                  child: Text('Add'),
                ),
              ],
            ),
            Divider(height: 30),
            Expanded(
              child: transactions.isEmpty
                  ? Center(child: Text('No transactions added yet'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        var tx = transactions[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              tx['type'] == 'Income'
                                  ? Icons.add_circle
                                  : Icons.remove_circle,
                              color: tx['type'] == 'Income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(tx['description']),
                            subtitle: Text(
                                '${tx['type']} - ₹${tx['amount'].toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
