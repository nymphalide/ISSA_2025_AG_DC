package com.carsharing.repository;

import com.carsharing.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Custom query method to find a user by their email for login
    User findByEmail(String email);
}