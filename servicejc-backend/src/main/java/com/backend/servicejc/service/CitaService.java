package com.backend.servicejc.service;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.model.Producto;
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
    private final ServicioService servicioService; // Inyectar ServicioService
    private final String COLLECTION_NAME = "citas";

    @Autowired
    // Añadir inyección de ServicioService
    public CitaService(Firestore firestore, ServicioService servicioService) { 
        this.firestore = firestore;
        this.servicioService = servicioService; 
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

    // MÉTODO MODIFICADO: Ahora devuelve DTOs enriquecidos
   public List<Cita> getAllCitas() throws Exception {
    CollectionReference citas = firestore.collection(COLLECTION_NAME);
    QuerySnapshot querySnapshot = citas.get().get();
    List<Cita> listaCitasEnriquecidas = new ArrayList<>(); 

    if (!querySnapshot.isEmpty()) {
        for (DocumentSnapshot doc : querySnapshot.getDocuments()) {
            Cita cita = doc.toObject(Cita.class);
            
            // DEBUG: Verificar los IDs
            System.out.println("IDs de servicios: " + cita.getServiciosSeleccionados());
            
            // 1. Obtener los productos
            List<Producto> productos = servicioService.getProductosByIds(cita.getServiciosSeleccionados());
            
            // DEBUG: Verificar los productos obtenidos
            System.out.println("Productos obtenidos: " + productos.size());
            productos.forEach(p -> System.out.println("  - " + p.getId() + ": " + p.getNombre()));

            // 2. ENRIQUECER
            cita.setProductosSeleccionados(productos);
            
            // DEBUG: Verificar que se asignaron
            System.out.println("Productos en cita: " + cita.getProductosSeleccionados().size());

            listaCitasEnriquecidas.add(cita); 
        }
    }
    return listaCitasEnriquecidas; 
    }
    
    // MÉTODO: Lógica para actualizar una Cita
    public Cita updateCita(String id, Cita citaDetails) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(COLLECTION_NAME).document(id);
        
        DocumentSnapshot snapshot = docRef.get().get();
        if (!snapshot.exists()) {
            throw new RuntimeException("Cita no encontrada con ID: " + id);
        }

        // Aplicar las actualizaciones. 
        // Usamos los campos existentes: tecnicoId, estado, serviciosSeleccionados, fechaHora, etc.
        docRef.update(
            "estado", citaDetails.getEstado(),
            "tecnicoId", citaDetails.getTecnicoId(), // Usando el campo 'tecnicoId' existente
            "serviciosSeleccionados", citaDetails.getServiciosSeleccionados(),
            "fechaHora", citaDetails.getFechaHora(), // Esto actualiza la fecha/hora completa
            "descripcion", citaDetails.getDescripcion(),
            "costoTotal", citaDetails.getCostoTotal()
        ).get();
        
        DocumentSnapshot updatedSnapshot = docRef.get().get();
        return updatedSnapshot.toObject(Cita.class);
    }
}