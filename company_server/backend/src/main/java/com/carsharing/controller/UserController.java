package com.carsharing.controller;

import com.carsharing.model.User;
import com.carsharing.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // Extremely KISS login/register endpoint.
    // If the email exists, it logs them in. If not, it registers them.
    @PostMapping("/login")
    public User loginOrRegister(@RequestParam String name, @RequestParam String email) {
        User existingUser = userRepository.findByEmail(email);

        if (existingUser != null) {
            return existingUser; // "Login" successful
        }

        // "Register" new user
        User newUser = new User();
        newUser.setName(name);
        newUser.setEmail(email);
        return userRepository.save(newUser);
    }
}