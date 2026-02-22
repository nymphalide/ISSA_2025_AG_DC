package com.carsharing;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CarSharingApplication {

    public static void main(String[] args) {
        // Bootstraps the embedded web server and starts the application
        SpringApplication.run(CarSharingApplication.class, args);
        System.out.println("Company Backend is running on port 8080...");
    }

}