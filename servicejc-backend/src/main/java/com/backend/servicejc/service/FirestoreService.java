package com.backend.servicejc.service;

import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

@Service
public class FirestoreService {

    public String testConnection() {
        Firestore db = FirestoreClient.getFirestore();
        return "Firestore conectado: " + (db != null);
    }
}
