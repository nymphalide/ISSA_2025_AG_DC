import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car.dart';

class ApiService {
  // Remember: 10.0.2.2 is the specific bridge IP for the Android Emulator
  // to talk to your Windows machine's localhost.
  static const String baseUrl = "http://10.0.2.2:8080/api";

  // 1. Get the list of available cars
  Future<List<Car>> fetchCars() async {
    final response = await http.get(Uri.parse('$baseUrl/cars'));

    if (response.statusCode == 200) {
      // Decode the JSON string into a Dart List
      List jsonResponse = json.decode(response.body);

      // Map each JSON object to our Car Model using the Factory pattern
      return jsonResponse.map((car) => Car.fromJson(car)).toList();
    } else {
      throw Exception('Failed to load cars from server');
    }
  }

  // 2. Start the rental (Unlock the Python car)
  Future<String> startRental(String vin) async {
    final response = await http.get(Uri.parse('$baseUrl/rental/start?vin=$vin'));
    return response.body; // Returns the "SUCCESS" or "ERROR" string
  }

  // 3. End the rental (Lock the Python car)
  Future<String> endRental(String vin) async {
    final response = await http.get(Uri.parse('$baseUrl/rental/end?vin=$vin'));
    return response.body;
  }

  // 4. Login / Register
  Future<bool> login(String name, String email) async {
    // Using POST as defined in our Java UserController
    final response = await http.post(
        Uri.parse('$baseUrl/users/login?name=$name&email=$email')
    );
    // If the server returns 200 OK, the login/registration worked.
    return response.statusCode == 200;
  }
}