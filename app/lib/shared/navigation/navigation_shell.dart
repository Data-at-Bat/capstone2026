import 'package:flutter/material.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
import 'package:app/features/historical_accuracy/presentation/screens/historical_accuracy_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DailyPredictionsPage(),
    MySubscriptionPage(),
    HistoricalAccuracyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data at Bat')),
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Daily Predictions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Subscription',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historical Accuracy',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
