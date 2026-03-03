package com.backend.servicejc.service; 

import com.backend.servicejc.model.Usuario;
// ❌ YA NO NECESITAMOS ESTO: import com.backend.servicejc.model.Rol;
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
        // Asegúrate de que el email coincida exactamente con lo que usas para loguearte
        String adminEmail = "Jcpublicaciones2829@hotmail.com";
        String adminPassword = "JCService2025";
        
        try {
            CollectionReference usuariosCollection = firestore.collection("usuarios");
            // Nota: Aquí usamos el email como ID del documento, asegúrate de que esa sea tu lógica
            DocumentSnapshot adminDoc = usuariosCollection.document(adminEmail).get().get();
            
            if (!adminDoc.exists()) {
                System.out.println("No se encontró usuario administrador. Creando uno por defecto...");
                
                Usuario adminUser = new Usuario();
                adminUser.setId(adminEmail);
                adminUser.setNombre("Administrador JC");
                adminUser.setCorreo(adminEmail);
                adminUser.setTelefono("N/A"); 
                
                String encodedPassword = passwordEncoder.encode(adminPassword);
                adminUser.setContrasena(encodedPassword);
                
                // ✅ CAMBIO IMPORTANTE: Ahora pasamos un String directo
                // Usamos mayúsculas por convención de Spring Security
                adminUser.setRol("ADMIN"); 

                // Si tu modelo Usuario tiene UserAddressModel y es obligatorio, inicialízalo vacío
                // adminUser.setDireccion(new UserAddressModel()); 

                usuariosCollection.document(adminUser.getId()).set(adminUser).get();
                System.out.println("✅ ¡Usuario administrador creado con éxito!");
            } else {
                System.out.println("ℹ️ El usuario administrador ya existe. No se sobrescribió.");
            }
        } catch (InterruptedException | ExecutionException e) {
            System.err.println("❌ Error al inicializar el usuario administrador: " + e.getMessage());
            e.printStackTrace();
        }
    }
}