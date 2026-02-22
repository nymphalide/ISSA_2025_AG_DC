package com.carsharing.controller;

import com.carsharing.model.Car;
import com.carsharing.repository.CarRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/cars") // Here is where that "fuck" endpoint finally comes from!
public class CarController {

    @Autowired
    private CarRepository carRepository;

    @GetMapping
    public List<Car> getAllCars() {
        // This fetches every row from your carsharing.db and
        // sends it as a JSON list to the phone app.
        return carRepository.findAll();
    }
}