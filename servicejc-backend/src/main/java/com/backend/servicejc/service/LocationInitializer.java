package com.backend.servicejc.config;

import com.backend.servicejc.service.LocationDataService;
import com.google.cloud.firestore.Firestore;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import java.util.concurrent.ExecutionException;

/**
 * Configuración para inicializar datos geográficos (Provincias, Distritos, Corregimientos)
 * en Firestore si la colección 'geolocations' está vacía al inicio de la aplicación.
 */
@Configuration
public class LocationInitializer {

    private static final Logger logger = LoggerFactory.getLogger(LocationInitializer.class);
    private static final String COLLECTION_NAME = "geolocations";

    @Bean
    public CommandLineRunner initLocations(Firestore firestore, LocationDataService locationDataService) {
        return args -> {
            logger.info("--- Iniciando el proceso de verificación de Ubicaciones ---");

            try {
                // 1. Verificar si la colección ya tiene datos (limitamos a 1 para mayor eficiencia)
                int count = firestore.collection(COLLECTION_NAME).limit(1).get().get().size();

                if (count == 0) {
                    logger.warn("La colección '{}' está vacía. Procediendo a la carga inicial de datos geográficos.", COLLECTION_NAME);
                    
                    // 2. Ejecutar el método de inicialización del servicio
                    String message = locationDataService.initializeLocations();
                    
                    logger.info("Inicialización completada: {}", message);
                } else {
                    logger.info("La colección '{}' ya contiene {} documento(s). Se omite la carga automática.", COLLECTION_NAME, count);
                }
            } catch (ExecutionException | InterruptedException e) {
                logger.error("Error crítico al inicializar las ubicaciones geográficas: {}", e.getMessage(), e);
                // Si la inicialización falla, se lanza una excepción para que el servidor falle
                throw new RuntimeException("Fallo en la inicialización de Firestore", e);
            }
        };
    }
}
