import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';

class ActiveRentalScreen extends StatefulWidget {
  final Car car;

  const ActiveRentalScreen({super.key, required this.car});

  @override
  State<ActiveRentalScreen> createState() => _ActiveRentalScreenState();
}

class _ActiveRentalScreenState extends State<ActiveRentalScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _lockCar() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking car state for ${widget.car.vin}...';
    });

    try {
      // Capture the exact string response from the backend
      String result = await _apiService.endRental(widget.car.vin);

      if (result.startsWith('SUCCESS')) {
        if (mounted) {
          // SUCCESS: Trip is over and car is safe. Pop this screen off the stack.
          Navigator.pop(context);
        }
      } else {
        // ERROR: The backend denied the request (e.g., doors open).
        // Update the UI state to show the user what to fix, DO NOT pop the screen.
        setState(() {
          _statusMessage = result;
          _isLoading = false;
        });
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
    // We use a WillPopScope (or back button interception) pattern here in a real app
    // to prevent the user from just swiping back while driving, but this is fine for now.
    return Scaffold(
      appBar: AppBar(
        title: Text('Driving ${widget.car.vin}'),
        automaticallyImplyLeading: false, // Hides the back arrow so they must press Lock
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text('Trip in progress...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _lockCar,
                icon: const Icon(Icons.lock),
                label: const Text('LOCK & END RENTAL', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),

            const SizedBox(height: 30),

            // Only show the box if there is actually a message
            if (_statusMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50, // Light red background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  border: Border.all(color: Colors.red.shade200), // Subtle border
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: Colors.red.shade900, // Darker text for readability
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}