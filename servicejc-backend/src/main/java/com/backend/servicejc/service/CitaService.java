package com.backend.servicejc.service;

import com.backend.servicejc.model.Cita;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot; // Importación necesaria
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class CitaService {

    private final Firestore firestore;
    private final String COLLECTION_NAME = "citas";

    @Autowired
    public CitaService(Firestore firestore) {
        this.firestore = firestore;
    }

    // Método para crear una nueva cita
    public void createCita(Cita cita) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
        cita.setId(docRef.getId());
        ApiFuture<com.google.cloud.firestore.WriteResult> result = docRef.set(cita);
        result.get();
    }

    // Método para obtener las citas de un usuario específico
    public List<Cita> getCitasByUsuarioId(String usuarioId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("usuarioId", usuarioId)
                .get();

        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Cita> citas = new ArrayList<>();
        for (QueryDocumentSnapshot document : documents) {
            citas.add(document.toObject(Cita.class));
        }
        return citas;
    }

    // Método para obtener todas las citas
    public List<Cita> getAllCitas() throws Exception {
        CollectionReference citas = firestore.collection(COLLECTION_NAME);
        QuerySnapshot querySnapshot = citas.get().get();
        List<Cita> listaCitas = new ArrayList<>();

        if (!querySnapshot.isEmpty()) {
            for (DocumentSnapshot doc : querySnapshot.getDocuments()) {
                listaCitas.add(doc.toObject(Cita.class));
            }
        }
        return listaCitas;
    }
}