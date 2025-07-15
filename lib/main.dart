import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/main_navigation.dart';

void main() {
  // Initialize database for web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  runApp(const HouseProjectLogger());
}

class HouseProjectLogger extends StatelessWidget {
  const HouseProjectLogger({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Project Logger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}