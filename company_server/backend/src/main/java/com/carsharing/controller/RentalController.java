package com.carsharing.controller;

import com.carsharing.service.RentalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rental")
public class RentalController {

    @Autowired
    private RentalService rentalService;

    // Trigger this via browser: http://localhost:8080/api/rental/start?vin=VIN001
    @GetMapping("/start")
    public String start(@RequestParam String vin) {
        return rentalService.startRental(vin);
    }

    // Trigger this via browser: http://localhost:8080/api/rental/end?vin=VIN001
    @GetMapping("/end")
    public String end(@RequestParam String vin) {
        return rentalService.endRental(vin);
    }
}