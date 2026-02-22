package com.carsharing.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "cars")
public class Car {
    @Id
    private String vin; // Vehicle Identification Number
    private String location; // e.g., "Campus A"
    private boolean isAvailable; // To track if someone is already renting it

    public Car() {}

    public Car(String vin, String location, boolean isAvailable) {
        this.vin = vin;
        this.location = location;
        this.isAvailable = isAvailable;
    }

    // Getters and Setters
    public String getVin() { return vin; }
    public void setVin(String vin) { this.vin = vin; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean available) { isAvailable = available; }
}