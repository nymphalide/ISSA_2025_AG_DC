import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';


// We use a StatefulWidget to hold the data so it doesn't reload every time you scroll.
class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Car>> _futureCars;

  @override
  void initState() {
    super.initState();
    // Lifecycle pattern: We trigger the network request exactly once when the screen loads.
    _futureCars = _apiService.fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Cars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_email'); // Clear the session
              if (mounted) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              }
            },
          )
        ],
      ),
      // FutureBuilder implements the Observer pattern. It watches the network request
      // and redraws the UI automatically when the data arrives or if an error happens.
      body: FutureBuilder<List<Car>>(
        future: _futureCars,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cars found in the database.'));
          }

          List<Car> cars = snapshot.data!;

          // ListView.builder uses the Builder pattern to only render items currently
          // visible on the screen, saving memory.
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              Car car = cars[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text(car.vin),
                subtitle: Text('Location: ${car.location}'),
                trailing: car.isAvailable
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
                onTap: () {
                  // <-- 2. UPDATED ON-TAP LOGIC HERE
                  if (car.isAvailable) {
                    // Push the new screen onto the stack
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailsScreen(car: car),
                      ),
                    ).then((_) {
                      // Observer pattern: Refresh list when returning from the rental screens
                      setState(() {
                        _futureCars = _apiService.fetchCars();
                      });
                    });
                  } else {
                    // Show a popup warning for unavailable cars
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This car is currently unavailable.')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _futureCars = _apiService.fetchCars();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}