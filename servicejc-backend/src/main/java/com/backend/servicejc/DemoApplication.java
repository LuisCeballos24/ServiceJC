package com.backend.servicejc;

import com.backend.servicejc.service.ServicioService; // Importar el servicio
import com.backend.servicejc.service.AdminInitializer; // Suponiendo que también lo necesitas
import com.backend.servicejc.service.LocationInitializer; // Suponiendo que también lo necesitas
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    // Asegúrate de que el ServicioService esté disponible como Bean (paso 1)
    @Bean
    public CommandLineRunner commandLineRunner(
        ServicioService servicioService, // <- Inyección aquí
        AdminInitializer adminInitializer,
        LocationInitializer locationInitializer
    ) {
        return args -> {
            // Lógica de inicialización al inicio de la aplicación
        };
    }
}