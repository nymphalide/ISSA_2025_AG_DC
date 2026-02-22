package com.carsharing.websocket;

import com.carsharing.model.Car;
import com.carsharing.repository.CarRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class CarWebSocketHandler extends TextWebSocketHandler {

    @Autowired
    private CarRepository carRepository;

    private static final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    // Synchronous-to-Asynchronous Bridge pattern implementation
    // Holds the pending requests waiting for a STATE_REPORT from the Python car
    private static final Map<String, CompletableFuture<Map<String, Object>>> pendingStateRequests = new ConcurrentHashMap<>();

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // Changed to Map<String, Object> to handle nested JSON payloads correctly
        Map<String, Object> data = objectMapper.readValue(message.getPayload(), Map.class);
        String action = (String) data.get("action");

        if ("REGISTER_CAR".equals(action)) {
            String vin = (String) data.get("vin");

            Optional<Car> optionalCar = carRepository.findById(vin);

            if (optionalCar.isPresent()) {
                Car car = optionalCar.get();
                sessions.put(vin, session);

                boolean isRented = !car.isAvailable();

                String responseJson = String.format(
                        "{\"status\":\"SUCCESS\", \"message\":\"Registered\", \"is_rented\": %b}",
                        isRented
                );

                session.sendMessage(new TextMessage(responseJson));
                System.out.println("Car verified and connected: " + vin + " | Sync state -> is_rented: " + isRented);
            } else {
                session.sendMessage(new TextMessage("{\"status\":\"ERROR\", \"message\":\"Unknown VIN\"}"));
                session.close();
                System.out.println("Rejected unknown VIN: " + vin);
            }
        }
        else if ("STATE_REPORT".equals(action)) {
            // Observer pattern handler: Reacts to incoming state reports from the Python mock
            Map<String, Object> payload = (Map<String, Object>) data.get("payload");
            String vin = (String) payload.get("vin");

            // Resolve the waiting Future
            CompletableFuture<Map<String, Object>> future = pendingStateRequests.remove(vin);
            if (future != null) {
                future.complete(payload);
            }
        }
    }

    public void sendCommand(String vin, String action) throws Exception {
        WebSocketSession session = sessions.get(vin);
        if (session != null && session.isOpen()) {
            session.sendMessage(new TextMessage("{\"action\":\"" + action + "\"}"));
        }
    }

    // New method for the Synchronous-to-Asynchronous Bridge pattern
    public CompletableFuture<Map<String, Object>> requestCarState(String vin) throws Exception {
        CompletableFuture<Map<String, Object>> future = new CompletableFuture<>();
        pendingStateRequests.put(vin, future);
        sendCommand(vin, "QUERY_STATE"); // Trigger the Python mock
        return future;
    }
}