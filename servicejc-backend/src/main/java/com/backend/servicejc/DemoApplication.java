package com.backend.servicejc;

import com.backend.servicejc.service.ServicioService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Bean
    public CommandLineRunner commandLineRunner(ServicioService servicioService) {
        return args -> {
            System.out.println("🚀 Ejecutando CommandLineRunner para poblar los servicios...");
            // Se ha cambiado el método de poblamiento aquí
            servicioService.seedCategoriasYProductos();
        };
    }
}