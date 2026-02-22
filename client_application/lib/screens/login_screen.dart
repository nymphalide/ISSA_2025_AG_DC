import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'car_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();

  // Controllers to grab the text from the input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _attemptLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Call the login endpoint we built in Spring Boot
      bool success = await _apiService.login(
          _nameController.text.trim(),
          _emailController.text.trim()
      );

      if (success) {
        // PERSISTENCE PATTERN: Save email to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _emailController.text.trim());

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CarListScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your details.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Is the server running?';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Sharing Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blue),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _attemptLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Makes button full width
                ),
                child: const Text('LOGIN / REGISTER', style: TextStyle(fontSize: 18)),
              ),

            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}