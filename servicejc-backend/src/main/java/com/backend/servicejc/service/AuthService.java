package com.backend.servicejc.service;

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
    public String loginUser(LoginDto loginDto) throws ExecutionException, InterruptedException {
        // Busca el usuario por correo
        ApiFuture<QuerySnapshot> query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("correo", loginDto.getCorreo())
                .get();

        List<QueryDocumentSnapshot> documents = query.get().getDocuments();
        if (documents.isEmpty()) {
            throw new IllegalArgumentException("Credenciales incorrectas.");
        }

        Usuario usuario = documents.get(0).toObject(Usuario.class);
        
        // En un entorno real, aquí se debería comparar la contraseña encriptada
        // if (!passwordEncoder.matches(loginDto.getContrasena(), usuario.getContrasena())) {
        if (!loginDto.getContrasena().equals(usuario.getContrasena())) {
            throw new IllegalArgumentException("Credenciales incorrectas.");
        }

        // Si las credenciales son correctas, puedes generar un token JWT aquí
        return "fake-jwt-token-para-usuario-" + usuario.getId();
    }
}