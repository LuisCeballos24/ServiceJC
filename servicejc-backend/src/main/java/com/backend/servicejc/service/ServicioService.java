package com.backend.servicejc.service;

import com.backend.servicejc.model.Producto;
import com.backend.servicejc.model.Servicio;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Service
public class ServicioService {

    private final Firestore firestore;

    @Autowired
    public ServicioService(Firestore firestore) {
        this.firestore = firestore;
    }

    public List<Servicio> getAllCategorias() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection("servicios").get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        return documents.stream()
                .map(doc -> doc.toObject(Servicio.class))
                .collect(Collectors.toList());
    }

    public List<Producto> getProductosByServicioId(String servicioId) throws ExecutionException, InterruptedException {
    ApiFuture<QuerySnapshot> future = firestore.collection("productos")
            .whereEqualTo("servicioId", servicioId)
            .get();
    List<QueryDocumentSnapshot> documents = future.get().getDocuments();
    return documents.stream()
            .map(doc -> doc.toObject(Producto.class))
            .collect(Collectors.toList());
}

    // Método de poblamiento mejorado
    public void seedCategoriasYProductos() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> futureServicios = firestore.collection("servicios").get();
        if (!futureServicios.get().isEmpty()) {
            System.out.println("Las colecciones ya contienen datos. No se poblarán.");
            return;
        }

        System.out.println("Poblando colecciones 'servicios' y 'productos'...");

        // 1. Población de Categorías (Servicios) y almacenamiento de IDs en un mapa
        Map<String, String> categoriaIds = new HashMap<>();
        List<String> nombresCategorias = Arrays.asList(
            "Electricidad", "Plomería", "Carpintería", 
            "Jardinería", "Limpieza", "Cerrajería"
        );

        for (String nombre : nombresCategorias) {
            Servicio categoria = new Servicio(null, nombre);
            ApiFuture<DocumentReference> addedDocRef = firestore.collection("servicios").add(categoria);
            categoriaIds.put(nombre, addedDocRef.get().getId());
        }

        // 2. Población de Productos (ítems específicos)
        List<Producto> productos = new ArrayList<>();
        
        // Obtenemos el ID de Electricidad de forma segura usando el nombre
        String idElectricidad = categoriaIds.get("Electricidad");
        if (idElectricidad != null) {
            productos.add(new Producto(null, "Lámpara", 25.00, idElectricidad));
            productos.add(new Producto(null, "Tomas", 25.00, idElectricidad));
            productos.add(new Producto(null, "Interruptores", 25.00, idElectricidad));
            productos.add(new Producto(null, "Breaker", 25.00, idElectricidad));
            productos.add(new Producto(null, "Abanico", 25.00, idElectricidad));
            productos.add(new Producto(null, "Otros", 25.00, idElectricidad));
        }

        // Puedes añadir más productos para otras categorías aquí
        // Por ejemplo:
        // String idPlomeria = categoriaIds.get("Plomería");
        // if (idPlomeria != null) {
        //     productos.add(new Producto(null, "Grifo", 20.00, idPlomeria));
        // }

        for (Producto producto : productos) {
            firestore.collection("productos").add(producto);
        }

        System.out.println("✅ Datos de categorías y productos poblados exitosamente.");
    }
}