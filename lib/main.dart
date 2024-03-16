// Sebastian Sanchez and Nohayla Messaoudi Project 01 main file
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'database_helper.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'intro_screen.dart';

final dbHelper = DatabaseHelper();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
// initialize the database
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

String month = "March";

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> dataMap = {
    "Food": 0,
    "Transportation": 0,
    "Entertainment": 0,
    "Rent and Utilities": 0,
    "Insurance": 0,
    "Other": 0,
  };
  double foodMonthlySpending = 0;
  double transportationMonthlySpending = 0;
  double entertainmentMonthlySpending = 0;
  double rentMonthlySpending = 0;
  double insuranceMonthlySpending = 0;
  double otherMontlySpending = 0;
  double totalMonthlySpending = 0;
  double monthlyEarnings = 0;
  double budget = 0;
  @override
  void initState() {
    super.initState();
    updateValues().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> updateValues() async {
    dataMap['Food'] = await _queryCategory('Food') as double;
    dataMap['Transportation'] =
        await _queryCategory('Transportation') as double;
    dataMap['Entertainment'] = await _queryCategory('Entertainment') as double;
    dataMap['Rent and Utilities'] =
        await _queryCategory('Rent and Utilities') as double;
    dataMap['Insurance'] = await _queryCategory('Insurance') as double;
    dataMap['Other'] = await _queryCategory('Other') as double;
    monthlyEarnings = await _queryCategory("Earning") as double;
    budget = await _queryCategory("Budget") as double;

    foodMonthlySpending = dataMap['Food'] as double;
    transportationMonthlySpending = dataMap['Transportation'] as double;
    entertainmentMonthlySpending = dataMap['Entertainment'] as double;
    rentMonthlySpending = dataMap['Rent and Utilities'] as double;
    insuranceMonthlySpending = dataMap['Insurance'] as double;
    otherMontlySpending = dataMap['Other'] as double;
    totalMonthlySpending = getTotalMonthlySpending();
  }

  Future<double> _queryCategory(String category) async {
    double amount = await dbHelper.queryCategory(category);
    return amount;
  }

  double getTotalMonthlySpending() {
    double totalMonthlySpending = 0;
    for (MapEntry<String, double> spending in dataMap.entries) {
      totalMonthlySpending += spending.value;
    }
    return totalMonthlySpending;
  }

  void _refreshData() {
    updateValues().whenComplete(() {
      setState(() {});
    });
  }

  final colorList = <Color>[
    Colors.lightBlue,
    Colors.amber,
    Colors.deepOrange,
    Colors.pink,
    Colors.green,
    Colors.purple,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.title),
      ),
      body: ListView(padding: EdgeInsets.all(10), children: <Widget>[
        const SizedBox(
          height: 50,
        ),
        Center(
          child: pie.PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 2.5,
            colorList: colorList,
            initialAngleInDegree: 0,
            chartType: pie.ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "$month \nSpending",
            legendOptions: const pie.LegendOptions(
              showLegendsInRow: false,
              legendPosition: pie.LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: const pie.ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: true,
              decimalPlaces: 1,
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Container(
          height: 250,
          padding: EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: budget * 2.8,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: bottomTitles,
                  ),
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: monthlyEarnings,
                      color: Colors.green,
                      width: 25,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: budget,
                      color: Colors.blue,
                      width: 25,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: totalMonthlySpending,
                      color: Colors.red,
                      width: 25,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Text(
          "This month you have spent ${formatDoubleValue(totalMonthlySpending)} and you have earned ${formatDoubleValue(monthlyEarnings)}. Your Budget is ${formatDoubleValue(budget)}",
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransactionScreen()))
                  .then((_) => _refreshData());
            },
            child: Text("Add Transaction")),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Food:\t \$${formatDoubleValue(foodMonthlySpending)}"),
          tileColor: colorList[0],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text(
              "Transportation:\t \$${formatDoubleValue(transportationMonthlySpending)}"),
          tileColor: colorList[1],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text(
              "Entertainment:\t\$ ${formatDoubleValue(entertainmentMonthlySpending)}"),
          tileColor: colorList[2],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text(
              "Rent and Utilities:\t\$ ${formatDoubleValue(rentMonthlySpending)}"),
          tileColor: colorList[3],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text(
              "Insurance:\t \$${formatDoubleValue(insuranceMonthlySpending)}"),
          tileColor: colorList[4],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Other:\t\$${formatDoubleValue(otherMontlySpending)}"),
          tileColor: colorList[5],
        ),
        SizedBox(
          height: 50,
        ),
        /*       ElevatedButton(onPressed: _query, child: Text("Print All Rows")),
        ElevatedButton(
            onPressed: () async {
              double foodAmount = await _queryCategory('Food');
              print('Total food is: $foodAmount');
            },
            child: Text("Query Food")), */
      ]),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Earnings', 'Budget', 'Spending'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
  }

  String formatDoubleValue(double amount) {
    return amount.toStringAsFixed(2);
  }
}

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});
  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("Add Transaction"),
        ),
        body: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                FormBuilderTextField(
                  name: 'Transaction Amount',
                  decoration: const InputDecoration(
                      labelText: 'Transaction Amount',
                      border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    } else if (!value.contains(RegExp(r'\.')) ||
                        value.length < 4 ||
                        value.contains(RegExp(r'[a-zA-Z]'))) {
                      return 'Please enter a valid dollar amount with a period and cents';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 50,
                ),
                FormBuilderDropdown(
                  name: 'Transaction Category',
                  initialValue: 'Food',
                  items: [
                    "Food",
                    "Transportation",
                    "Entertainment",
                    "Rent and Utilities",
                    "Insurance",
                    "Other",
                    "Earning",
                  ].map((e) {
                    return DropdownMenuItem(
                      child: Text(e),
                      value: e,
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                      labelText: 'Transaction Category',
                      border: OutlineInputBorder()),
                ),
                SizedBox(
                  height: 50,
                ),
                FormBuilderDateTimePicker(
                  name: 'Transaction Date',
                  firstDate: DateTime(2024, 1, 1),
                  lastDate: DateTime(2024, 12, 31),
                  decoration: InputDecoration(
                    labelText: 'To Select the date Click Here',
                    border: OutlineInputBorder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 145),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction Added!')),
                        );

                        _formKey.currentState?.saveAndValidate();

                        _insert(_formKey.currentState?.value);

                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            )));
  }

  void _insert(Map<String, dynamic>? row) async {
    List? valueList = row?.values.toList();

    if (valueList != null) {
      String category = valueList[1].toString();
      double amount = double.parse(valueList[0].toString());
      String date = valueList[2].toString();

      Map<String, dynamic> rowHelper = {
        DatabaseHelper.columnTransactionCategory: category,
        DatabaseHelper.columnTransactionAmount: amount,
        DatabaseHelper.columnTransactionDate: date
      };

      await dbHelper.insert(rowHelper);
      print("Insert into Database success");
    }
  }
}
