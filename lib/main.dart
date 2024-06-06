import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_discover/screens/splash_screen.dart';

class ThemeManager with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get currentTheme => _isDarkMode ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          theme: themeManager.currentTheme,
          debugShowCheckedModeBanner: false, // Disable debug banner
          title: 'Self Discover',
          home: SplashScreen(
          ),
          builder: (context, child) {
            return Center(
              child: Container(
                //width: 500,
                //height: 800,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}