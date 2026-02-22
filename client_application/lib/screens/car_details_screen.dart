import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'active_rental_screen.dart'; // We will create this next

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _unlockCar() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Unlocking ${widget.car.vin}...';
    });

    try {
      String result = await _apiService.startRental(widget.car.vin);

      if (mounted) {
        if (result.startsWith("SUCCESS")) {
          // Normal flow
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActiveRentalScreen(car: widget.car)),
          ).then((_) {
            if (mounted) Navigator.pop(context);
          });
        } else {
          // THE FIX: Show the "Car already taken" error from the backend
          setState(() {
            _statusMessage = result; // e.g. "Error: This car was just rented..."
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to connect to server.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rent ${widget.car.vin}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text('Location: ${widget.car.location}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),

            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _unlockCar,
                icon: const Icon(Icons.lock_open),
                label: const Text('UNLOCK & START RENTAL', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

            const SizedBox(height: 30),
            Text(_statusMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}