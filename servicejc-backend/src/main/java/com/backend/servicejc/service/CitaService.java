package com.backend.servicejc.service;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.model.Producto;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class CitaService {

    private final Firestore firestore;
    private final ServicioService servicioService;
    private final String COLLECTION_NAME = "citas";

    @Autowired
    public CitaService(Firestore firestore, ServicioService servicioService) {
        this.firestore = firestore;
        this.servicioService = servicioService;
    }

    // =========================================================================
    // 1. CREAR CITA 
    // =========================================================================
    public String createCita(Cita cita) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
        
        String generatedId = docRef.getId();
        cita.setId(generatedId);

        // ✅ CORRECCIÓN 1: Usamos getEstado() y setEstado() en lugar de status
        if (cita.getEstado() == null) {
            cita.setEstado("PENDIENTE_PAGO");
        }

        ApiFuture<WriteResult> result = docRef.set(cita);
        result.get(); 

        return generatedId;
    }

    // =========================================================================
    // 2. OBTENER POR USUARIO 
    // =========================================================================
    public List<Cita> getCitasByUsuarioId(String usuarioId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("usuarioId", usuarioId)
                .get();

        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Cita> citas = new ArrayList<>();

        for (QueryDocumentSnapshot document : documents) {
            Cita cita = document.toObject(Cita.class);
            enrichCitaWithProducts(cita);
            citas.add(cita);
        }
        return citas;
    }

    // =========================================================================
    // 3. OBTENER POR TÉCNICO 
    // =========================================================================
    public List<Cita> getCitasByTecnicoId(String tecnicoId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("tecnicoId", tecnicoId)
                .get();

        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Cita> citas = new ArrayList<>();

        for (QueryDocumentSnapshot document : documents) {
            Cita cita = document.toObject(Cita.class);
            enrichCitaWithProducts(cita);
            citas.add(cita);
        }
        return citas;
    }

    // =========================================================================
    // 4. OBTENER TODAS 
    // =========================================================================
    public List<Cita> getAllCitas() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME).get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Cita> citas = new ArrayList<>();

        for (QueryDocumentSnapshot document : documents) {
            Cita cita = document.toObject(Cita.class);
            enrichCitaWithProducts(cita);
            citas.add(cita);
        }
        return citas;
    }

    // =========================================================================
    // 5. OBTENER POR ID 
    // =========================================================================
    public Cita getCitaById(String id) throws ExecutionException, InterruptedException {
        DocumentSnapshot doc = firestore.collection(COLLECTION_NAME).document(id).get().get();
        if (doc.exists()) {
            Cita cita = doc.toObject(Cita.class);
            if (cita != null) {
                cita.setId(doc.getId());
                enrichCitaWithProducts(cita);
            }
            return cita;
        }
        return null;
    }

    // =========================================================================
    // 6. ACTUALIZAR CITA
    // =========================================================================
    public Cita updateCita(String id, Cita citaDetails) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(COLLECTION_NAME).document(id);

        if (!docRef.get().get().exists()) {
            throw new RuntimeException("Cita no encontrada");
        }

        Map<String, Object> updates = new HashMap<>();
        
        // ✅ CORRECCIÓN 2: Eliminamos getStatus(), getFecha() y getHora()
        // y usamos los métodos reales de tu modelo: getEstado() y getFechaHora()
        if (citaDetails.getEstado() != null) updates.put("estado", citaDetails.getEstado());
        if (citaDetails.getTecnicoId() != null) updates.put("tecnicoId", citaDetails.getTecnicoId());
        if (citaDetails.getFechaHora() != null) updates.put("fechaHora", citaDetails.getFechaHora());
        if (citaDetails.getDescripcion() != null) updates.put("descripcion", citaDetails.getDescripcion());
        if (citaDetails.getImageUrl() != null) updates.put("imageUrl", citaDetails.getImageUrl());

        if (!updates.isEmpty()) {
            docRef.update(updates).get();
        }

        return getCitaById(id);
    }

    // =========================================================================
    // MÉTODO AUXILIAR PRIVADO 
    // =========================================================================
    private void enrichCitaWithProducts(Cita cita) {
        try {
            if (cita.getServiciosSeleccionados() != null && !cita.getServiciosSeleccionados().isEmpty()) {
                List<Producto> productos = servicioService.getProductosByIds(cita.getServiciosSeleccionados());
                cita.setProductosSeleccionados(productos);
            }
        } catch (Exception e) {
            System.err.println("Error enriqueciendo cita " + cita.getId() + ": " + e.getMessage());
            cita.setProductosSeleccionados(new ArrayList<>());
        }
    }
}