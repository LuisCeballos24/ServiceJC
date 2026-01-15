package com.backend.servicejc.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;

@Configuration
public class FirebaseConfig {

    // Asegúrate de que esta variable esté en tu application.properties
    // Si no estás seguro, puedes reemplazar 'bucketName' abajo por "servicejc-d3aca.appspot.com"
    @Value("${firebase.storage.bucket-name}")
    private String bucketName;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        // ID DE TU PROYECTO (Lo tomé de tus logs anteriores)
        String projectId = "servicejc-d3aca"; 

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.getApplicationDefault())
                .setProjectId(projectId) // <--- ¡ESTA ES LA SOLUCIÓN!
                .setStorageBucket(bucketName) 
                .setDatabaseUrl("https://" + projectId + ".firebaseio.com") 
                .build();

        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp app = FirebaseApp.initializeApp(options);
            System.out.println("🔥 Firebase inicializado para proyecto: " + projectId);
            return app;
        } else {
            return FirebaseApp.getInstance();
        }
    }

    @Bean
    public Firestore firestore(FirebaseApp firebaseApp) {
        return FirestoreClient.getFirestore(firebaseApp);
    }
    
    @Bean
    public Storage storage() {
        // También especificamos el proyecto aquí por seguridad
        return StorageOptions.newBuilder()
                .setProjectId("servicejc-d3aca")
                .build()
                .getService();
    }
}