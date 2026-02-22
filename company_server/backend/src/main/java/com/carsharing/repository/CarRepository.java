package com.carsharing.repository;

import com.carsharing.model.Car;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CarRepository extends JpaRepository<Car, String> {
    // Just find cars that aren't currently being rented
    List<Car> findByIsAvailableTrue();

    // Pessimistic Locking Pattern: Tells the database to lock this specific row
    // against concurrent reads/writes until the current transaction commits.
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT c FROM Car c WHERE c.vin = :vin")
    Optional<Car> findByIdWithLock(@Param("vin") String vin);
}