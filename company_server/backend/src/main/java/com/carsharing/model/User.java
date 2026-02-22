package com.carsharing.model;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private String clientId; // The unique identifier for the phone app
    private String name;
    private String email;

    // Standard empty constructor for JPA
    public User() {}

    public User(String clientId, String name, String email) {
        this.clientId = clientId;
        this.name = name;
        this.email = email;
    }

    // Getters and Setters
    public String getClientId() { return clientId; }
    public void setClientId(String clientId) { this.clientId = clientId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}