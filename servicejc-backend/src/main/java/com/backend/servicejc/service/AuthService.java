package com.backend.servicejc.service;

import com.backend.servicejc.model.AuthResponse;
import com.backend.servicejc.model.LoginDto;
import com.backend.servicejc.model.Usuario;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.DocumentReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.concurrent.ExecutionException;
import java.util.List;

@Service
public class AuthService {

    private final Firestore firestore;
    private final String COLLECTION_NAME = "usuarios";

    @Autowired
    public AuthService(Firestore firestore) {
        this.firestore = firestore;
    }

    // Método para registrar un nuevo usuario
    public void registerUser(Usuario usuario) throws ExecutionException, InterruptedException {
        // En un entorno real, aquí se debería encriptar la contraseña antes de guardarla
        // String hashedPassword = passwordEncoder.encode(usuario.getContrasena());
        // usuario.setContrasena(hashedPassword);

        // Verifica si el correo ya está registrado
        ApiFuture<QuerySnapshot> query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("correo", usuario.getCorreo())
                .get();

        List<QueryDocumentSnapshot> documents = query.get().getDocuments();
        if (!documents.isEmpty()) {
            throw new IllegalArgumentException("El correo ya está registrado.");
        }

        firestore.collection(COLLECTION_NAME).add(usuario);
    }

    // Método para autenticar un usuario
   public AuthResponse loginUser(LoginDto loginDto) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("correo", loginDto.getCorreo())
                .get();

        List<QueryDocumentSnapshot> documents = query.get().getDocuments();
        if (documents.isEmpty()) {
            System.out.println("Login Failed: User not found for email: " + loginDto.getCorreo());
            throw new IllegalArgumentException("Credenciales incorrectas.");
        }

        Usuario usuario = documents.get(0).toObject(Usuario.class);
        System.out.println("Login Attempt: Found user " + usuario.getCorreo());
        System.out.println("Provided Password: " + loginDto.getContrasena());
        System.out.println("Stored Password: " + usuario.getContrasena());

        // CORRECCIÓN: La contraseña no está encriptada, por lo tanto, no se puede usar BCryptPasswordEncoder.
        if (!loginDto.getContrasena().equals(usuario.getContrasena())) {
            System.out.println("Login Failed: Password mismatch for user: " + usuario.getCorreo());
            throw new IllegalArgumentException("Credenciales incorrectas.");
        }
        
        String token = "fake-jwt-token-for-user-" + documents.get(0).getId();
        String userRoleString = null;
        
        if (usuario.getRol() != null) {
            userRoleString = usuario.getRol().name(); // Asumiendo que Rol es un enum
        }
        
        AuthResponse response = new AuthResponse(token, userRoleString, usuario.getId()); // <-- AGREGAR userId al constructor
        
        System.out.println("Login Successful: Returning AuthResponse -> Token: " + response.getToken() + ", Rol: " + response.getRol() + ", userId: " + response.getUserId());
        System.out.println("Login Successful: " + response);
        
        return response;
    }
}
