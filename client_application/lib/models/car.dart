class Car {
  final String vin;
  final String location;
  final bool isAvailable;

  // This is the constructor. It initializes the object.
  Car({
    required this.vin,
    required this.location,
    required this.isAvailable
  });

  /**
   * This is a 'factory' constructor.
   * It takes a 'Map' (JSON) and converts it into an instance of Car.
   * This is the bridge between your Java backend and your Flutter frontend.
   */
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      vin: json['vin'],
      location: json['location'],
      // We use 'available' here because Java boolean fields often
      // get serialized without the 'is' prefix in the JSON key.
      isAvailable: json['available'] ?? false,
    );
  }
}