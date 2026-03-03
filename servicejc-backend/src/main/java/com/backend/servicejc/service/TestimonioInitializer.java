package com.backend.servicejc.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class TestimonioInitializer implements CommandLineRunner {

    private final TestimonioService testimonioService;

    @Autowired
    public TestimonioInitializer(TestimonioService testimonioService) {
        this.testimonioService = testimonioService;
    }

    @Override
    public void run(String... args) {
        try {
            System.out.println("🏁 Iniciando verificación de Testimonios...");
            testimonioService.seedTestimonios();
        } catch (Exception e) {
            System.err.println("❌ Error en TestimonioInitializer: " + e.getMessage());
        }
    }
}