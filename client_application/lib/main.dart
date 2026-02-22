import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/car_list_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Ensure Flutter is initialized before trying to access local storage
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final String? savedEmail = prefs.getString('user_email');

  runApp(CarSharingApp(startScreen: savedEmail != null
      ? const CarListScreen()
      : const LoginScreen()
  ));
}

class CarSharingApp extends StatelessWidget {
  final Widget startScreen;
  const CarSharingApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Sharing Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // STRATEGY PATTERN: Choose the screen based on auth state
      home: startScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}