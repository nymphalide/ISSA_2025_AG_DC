package com.carsharing.service;

import com.carsharing.model.Car;
import com.carsharing.repository.CarRepository;
import com.carsharing.websocket.CarWebSocketHandler;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RentalService {

    @Autowired
    private CarRepository carRepository;

    @Autowired
    private CarWebSocketHandler webSocketHandler;

    // Utilizing the Pessimistic Locking pattern at the database level instead of JVM synchronization
    @Transactional // Ensures database integrity
    public String startRental(String vin) {
        // 1. PESSIMISTIC LOCK: Pull the state from SQLite and lock the row
        Car car = carRepository.findByIdWithLock(vin).orElse(null);

        if (car == null) return "Error: Car not found.";

        // 2. THE LOCK: If another thread saved 'available = false' while this thread was waiting,
        // this check will now fail for the second user.
        if (!car.isAvailable()) {
            return "Error: This car was just rented by another user. Please refresh your list.";
        }

        try {
            // 3. Update DB FIRST to "claim" the car before even talking to the Python script
            car.setAvailable(false);
            carRepository.save(car);

            // 4. Then try to unlock
            webSocketHandler.sendCommand(vin, "UNLOCK_CAR");
            return "SUCCESS: Rental started.";
        } catch (Exception e) {
            // Rollback: If Python is offline, make car available again
            car.setAvailable(true);
            carRepository.save(car);
            return "Error: Car telematics unreachable.";
        }
    }

    public String endRental(String vin) {
        Car car = carRepository.findById(vin).orElse(null);

        if (car == null) return "Error: Car not found.";

        try {
            // 1. Synchronous-to-Asynchronous Bridge pattern: Request state and block thread
            java.util.concurrent.CompletableFuture<java.util.Map<String, Object>> futureState = webSocketHandler.requestCarState(vin);

            // 2. Wait up to 5 seconds for the Python mock to reply
            java.util.Map<String, Object> state = futureState.get(5, java.util.concurrent.TimeUnit.SECONDS);

            // 3. Evaluate the physical state
            boolean doorsClosed = (boolean) state.get("doors_closed");
            boolean lightsOff = (boolean) state.get("lights_off");

            if (!doorsClosed || !lightsOff) {
                // Using the Builder pattern to dynamically construct a user-friendly message
                StringBuilder errorMsg = new StringBuilder("Cannot end rental. Please fix the following: ");
                if (!doorsClosed) {
                    errorMsg.append("Close all doors. ");
                }
                if (!lightsOff) {
                    errorMsg.append("Turn off the exterior lights.");
                }
                return errorMsg.toString().trim();
            }

            // 4. Send the LOCK command only if safe
            webSocketHandler.sendCommand(vin, "LOCK_CAR");

            // Make the car available for the next person
            car.setAvailable(true);
            carRepository.save(car);

            return "SUCCESS: Rental ended. Car " + vin + " locked.";

        } catch (java.util.concurrent.TimeoutException e) {
            return "Error: Car did not respond to state query in time. Is it online?";
        } catch (Exception e) {
            return "Error: Could not communicate with car.";
        }
    }
}