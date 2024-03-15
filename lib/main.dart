import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'database_helper.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fl_chart/fl_chart.dart';

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
      home: const MyHomePage(title: 'Monthly Spending Report'),
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
double monthlyEarnings = 2500.21;
double foodMonthlySpending = 250;
double transportationMonthlySpending = 175;
double entertainmentMonthlySpending = 100;
double rentMonthlySpending = 175;
double insuranceMonthlySpending = 300;
double otherMontlySpending = 50;

class _MyHomePageState extends State<MyHomePage> {
  Map<String, double> dataMap = {
    "Food": foodMonthlySpending,
    "Transportation": transportationMonthlySpending,
    "Entertainment": entertainmentMonthlySpending,
    "Rent and Utilites": rentMonthlySpending,
    "Insurance": insuranceMonthlySpending,
    "Other": otherMontlySpending,
  };

  double getTotalMonthlySpending() {
    double totalMonthlySpending = 0;
    for (MapEntry<String, double> spending in dataMap.entries) {
      totalMonthlySpending += spending.value;
    }
    return totalMonthlySpending;
  }

  void _refreshData() {
    setState(() {});
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
    double totalMonthlySpending = getTotalMonthlySpending();
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
              maxY: getTotalMonthlySpending() * 2.8,
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
          "This month you have spent $totalMonthlySpending and you have earned $monthlyEarnings",
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
          title: Text("Food:\t \$$foodMonthlySpending"),
          tileColor: colorList[0],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Transportation:\t \$$transportationMonthlySpending"),
          tileColor: colorList[1],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Entertainment:\t\$ $entertainmentMonthlySpending"),
          tileColor: colorList[2],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Rent and Utilities:\t\$ $rentMonthlySpending"),
          tileColor: colorList[3],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Insurance:\t \$$insuranceMonthlySpending"),
          tileColor: colorList[4],
        ),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text("Other:\t\$$otherMontlySpending"),
          tileColor: colorList[5],
        ),
        SizedBox(
          height: 50,
        ),
        ElevatedButton(onPressed: _query, child: Text("Print All Rows")),
      ]),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Earnings', 'Spending'];

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
