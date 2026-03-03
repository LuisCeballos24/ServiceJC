package com.backend.servicejc.service;

import com.backend.servicejc.model.Usuario;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.Query;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class UsuarioService {
    private final Firestore firestore;
    private static final String COLLECTION_NAME = "usuarios";

    public UsuarioService(Firestore firestore) {
        this.firestore = firestore;
    }

    public List<Usuario> getUsersByRole(String role) {
        List<Usuario> users = new ArrayList<>();
        Query query = firestore.collection(COLLECTION_NAME).whereEqualTo("rol", role);
        try {
            QuerySnapshot querySnapshot = query.get().get();
            for (DocumentSnapshot document : querySnapshot.getDocuments()) {
                users.add(document.toObject(Usuario.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }
        return users;
    }

    public void deleteUser(String userId) {
        DocumentReference userRef = firestore.collection(COLLECTION_NAME).document(userId);
        userRef.delete();
    }

    // MÉTODO 1: Buscar por Email (Para el Login)
    public Usuario getUsuarioByEmail(String email) throws ExecutionException, InterruptedException {
        // Buscamos en la colección "usuarios" donde el campo "email" sea igual al parámetro
        ApiFuture<QuerySnapshot> future = firestore.collection("usuarios")
                .whereEqualTo("email", email)
                .get();
        
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        
        if (!documents.isEmpty()) {
            // Devolvemos el primero que encontremos
            Usuario usuario = documents.get(0).toObject(Usuario.class);
            usuario.setId(documents.get(0).getId());
            return usuario;
        }
        return null; // No encontrado
    }

    // MÉTODO 2: Buscar por ID (Para el Filtro JWT)
    public Usuario getUsuarioById(String id) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection("usuarios").document(id);
        DocumentSnapshot document = docRef.get().get();

        if (document.exists()) {
            Usuario usuario = document.toObject(Usuario.class);
            if(usuario != null) usuario.setId(document.getId());
            return usuario;
        }
        return null;
    }
}