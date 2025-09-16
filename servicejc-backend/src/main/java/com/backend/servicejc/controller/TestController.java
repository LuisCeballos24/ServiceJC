package com.backend.precify.controller;

import com.backend.precify.service.FirestoreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @Autowired
    private FirestoreService firestoreService;

    @GetMapping("/test-firebase")
    public String testFirebase() {
        return firestoreService.testConnection();
    }
}