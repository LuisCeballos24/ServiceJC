package com.backend.servicejc.service; // Un paquete para los servicios

import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.model.Rol;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.DocumentSnapshot;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.util.concurrent.ExecutionException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;


@Component
public class AdminInitializer implements CommandLineRunner {

    private final Firestore firestore;
    private final BCryptPasswordEncoder passwordEncoder;

    public AdminInitializer(Firestore firestore, BCryptPasswordEncoder passwordEncoder) {
        this.firestore = firestore;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        String adminEmail = "Jcpublicaciones2829@hotmail.com";
        String adminPassword = "JCService2025";
        
        try {
            CollectionReference usuariosCollection = firestore.collection("usuarios");
            DocumentSnapshot adminDoc = usuariosCollection.document(adminEmail).get().get();
            
            if (!adminDoc.exists()) {
                System.out.println("No se encontró usuario administrador. Creando uno por defecto...");
                
                // Crea una nueva instancia del modelo Usuario
                Usuario adminUser = new Usuario();
                adminUser.setId(adminEmail);
                adminUser.setNombre("Administrador JC");
                adminUser.setCorreo(adminEmail);
                adminUser.setTelefono("N/A"); // O el teléfono que desees
                
                // Encripta la contraseña antes de guardarla
                String encodedPassword = passwordEncoder.encode(adminPassword);
                adminUser.setContrasena(encodedPassword);
                
                // Asigna el rol de ADMINISTRATIVO usando el enum
                adminUser.setRol(Rol.ADMINISTRATIVO);

                usuariosCollection.document(adminUser.getId()).set(adminUser).get();
                System.out.println("¡Usuario administrador creado con éxito!");
            } else {
                System.out.println("El usuario administrador ya existe. No se hará nada.");
            }
        } catch (InterruptedException | ExecutionException e) {
            System.err.println("Error al inicializar el usuario administrador: " + e.getMessage());
            e.printStackTrace();
        }
    }
}