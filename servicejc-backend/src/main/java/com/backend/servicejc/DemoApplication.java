package com.backend.servicejc;

import com.backend.servicejc.service.ServicioService; 
import com.backend.servicejc.service.AdminInitializer;
import com.backend.servicejc.service.LocationInitializer;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

    @Bean
    public CommandLineRunner commandLineRunner(
        ServicioService servicioService, // Inyección de ServicioService
        AdminInitializer adminInitializer,
        LocationInitializer locationInitializer
    ) {
        return args -> {
            System.out.println("🚀 Iniciando proceso de siembra de datos...");
            
            // 💡 1. LLAMADA CRUCIAL: Ejecuta el método de siembra
            servicioService.seedCategoriasYProductos(); 

            // 2. Ejecutar otros inicializadores (si son síncronos)
            // Ejemplo: adminInitializer.initialize();
            // Ejemplo: locationInitializer.initialize();
            
            System.out.println("✅ Proceso de siembra finalizado.");
        };
    }
}