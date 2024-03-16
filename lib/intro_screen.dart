import 'package:budget_buddy/database_helper.dart';
import 'package:budget_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _formKey = GlobalKey<FormState>();
  late double budget;
  late double monthlyIncome;
  late Map<String, double> expenseAllocations = {
    "Food": 0,
    "Transportation": 0,
    "Entertainment": 0,
    "Rent and Utilities": 0,
    "Insurance": 0,
    "Other": 0,
  };
  @override
  void initState() {
    super.initState();
    _checkIntroScreenStatus();
  }

  void _checkIntroScreenStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introScreenShown = prefs.getBool('introScreenShown') ?? false;
    if (introScreenShown) {
      // Intro screen has been shown before, navigate to another screen
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    // Navigate to the next screen, such as the home screen
    // You can use Navigator.pushReplacement() to prevent going back to the intro screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MyHomePage(
                title: 'Monthly Spending Report',
              )),
    );
  }

  void _saveIntroScreenStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('introScreenShown', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Buddy - Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget';
                    } else if (!value.contains(RegExp(r'\.')) ||
                        value.length < 4 ||
                        value.contains(RegExp(r'[a-zA-Z]'))) {
                      return 'Please enter a valid dollar amount with a period and cents';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    budget = double.parse(value!);
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Monthly Income'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter monthly income';
                    } else if (!value.contains(RegExp(r'\.')) ||
                        value.length < 4 ||
                        value.contains(RegExp(r'[a-zA-Z]'))) {
                      return 'Please enter a valid dollar amount with a period and cents';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    monthlyIncome = double.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                const Text('Expense Allocations:'),
                for (var entry in expenseAllocations.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(entry.key),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              } else if (!value.contains(RegExp(r'\.')) ||
                                  value.length < 4 ||
                                  value.contains(RegExp(r'[a-zA-Z]'))) {
                                return 'Please enter a valid dollar amount with a period and cents';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              expenseAllocations[entry.key] =
                                  double.parse(value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (_validateExpenseAllocations(
                          expenseAllocations.values.toList())) {
                        Map<String, dynamic> earnings = {
                          "Earning": monthlyIncome
                        };
                        Map<String, dynamic> budgetHelper = {"Budget": budget};
                        _insert(budgetHelper);
                        _insert(earnings);
                        _insert(expenseAllocations);
                        _saveIntroScreenStatus();
                        _navigateToNextScreen();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Total expense allocations exceed budget!'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }

  void _insert(Map<String, dynamic> allocations) async {
    DateTime now = DateTime.now();
    String date = DateTime(now.year, now.month, now.day).toString();
    for (String expense in allocations.keys.toList()) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnTransactionCategory: expense,
        DatabaseHelper.columnTransactionAmount:
            allocations[expense]?.toDouble(),
        DatabaseHelper.columnTransactionDate: date,
      };
      await dbHelper.insert(row);
    }
  }

  bool _validateExpenseAllocations(List<double> allocations) {
    final totalAllocations =
        allocations.reduce((value, element) => value + element);
    return totalAllocations <= budget;
  }
}
