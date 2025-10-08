package com.backend.servicejc.service;

import com.backend.servicejc.model.Usuario;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.Query;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.DocumentSnapshot;
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
}