package com.backend.servicejc.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.storage.Storage; // Importar Storage
import com.google.cloud.storage.StorageOptions; // Importar StorageOptions
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

@Configuration
public class FirebaseConfig {

    // Inyecta la ruta de la clave privada (ej: C:/Users/user/Documents/GitHub/serviceAccountKey.json)
    @Value("${FIREBASE_CREDENTIALS}")
    private String firebaseCredentialsPath;

    // Inyecta el nombre del bucket (ej: servicejc-d3aca.appspot.com)
    @Value("${firebase.storage.bucket-name}")
    private String bucketName;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        // 1. Cargar las credenciales desde la ruta de la clave privada
        FileInputStream serviceAccount = new FileInputStream(firebaseCredentialsPath);

        // 2. Construir las opciones de Firebase
        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                // CRUCIAL: Necesario para que Storage funcione correctamente
                .setStorageBucket(bucketName) 
                // URL base de tu proyecto
                .setDatabaseUrl("https://servicejc-d3aca.firebaseio.com") 
                .build();

        // 3. Inicializar y devolver la aplicación Firebase
        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp app = FirebaseApp.initializeApp(options);
            System.out.println("🔥 Firebase inicializado correctamente");
            return app;
        } else {
            return FirebaseApp.getInstance();
        }
    }

    @Bean
    public Firestore firestore(FirebaseApp firebaseApp) {
        return FirestoreClient.getFirestore(firebaseApp);
    }
    
    /**
     * Define el Bean de Google Cloud Storage (Storage Client).
     * CORRECCIÓN: Usa getDefaultInstance() que toma el contexto de autenticación global 
     * establecido por la inicialización de FirebaseApp.
     */
    @Bean
    public Storage storage() throws IOException {
        // Obtenemos el cliente de Google Cloud Storage. 
        // El SDK de Google Cloud encontrará automáticamente las credenciales 
        // configuradas por FirebaseApp.
        return StorageOptions.getDefaultInstance().getService();
    }
}