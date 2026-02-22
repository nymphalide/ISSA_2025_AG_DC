package com.carsharing.cli;

import com.carsharing.model.Car;
import com.carsharing.repository.CarRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Scanner;

@Component
public class AdminCli implements CommandLineRunner {

    @Autowired
    private CarRepository repository;

    @Override
    public void run(String... args) {
        // Run in a separate thread so it doesn't block the Web Server/WebSockets
        new Thread(() -> {
            Scanner scanner = new Scanner(System.in);
            System.out.println("\n--- ADMIN COMMAND LINE TOOL READY ---");
            System.out.println("Available: 'add', 'list', 'help'");

            while (true) {
                System.out.print("admin> ");
                String command = scanner.nextLine().trim().toLowerCase();

                switch (command) {
                    case "add":
                        addNewCar(scanner);
                        break;
                    case "list":
                        listCars();
                        break;
                    case "help":
                        System.out.println("Commands: add (register car), list (show database), exit");
                        break;
                    case "exit":
                        System.out.println("Exiting Admin CLI...");
                        return;
                    default:
                        System.out.println("Unknown command. Type 'help' for options.");
                }
            }
        }).start();
    }

    private void addNewCar(Scanner scanner) {
        System.out.print("Enter VIN: ");
        String vin = scanner.nextLine();
        System.out.print("Enter Location: ");
        String loc = scanner.nextLine();

        // Standard KISS logic: new cars are available by default
        repository.save(new Car(vin, loc, true));
        System.out.println("Car [" + vin + "] successfully saved to SQLite.");
    }

    private void listCars() {
        System.out.println("\n--- Registered Vehicles ---");
        repository.findAll().forEach(c ->
                System.out.printf("VIN: %s | Location: %s | Available: %b%n",
                        c.getVin(), c.getLocation(), c.isAvailable()));
    }
}