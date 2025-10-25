import 'package:flutter/material.dart';
import 'package:fishapp/pages/login_page.dart';
import 'package:fishapp/services/sqlite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SQLiteService().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atman',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}