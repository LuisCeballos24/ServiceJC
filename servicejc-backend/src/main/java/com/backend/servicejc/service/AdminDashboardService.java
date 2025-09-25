package com.backend.servicejc.service;

import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.model.Cita;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class AdminDashboardService {

    private final Firestore firestore;

    @Autowired
    public AdminDashboardService(Firestore firestore) {
        this.firestore = firestore;
    }

    public Map<String, Object> getMetrics() throws ExecutionException, InterruptedException {
        Map<String, Object> metrics = new HashMap<>();
        int tecnicosActivos = getTecnicosActivos();
        int citasActivas = getCitasActivas();
        double totalGanancias = getTotalGanancias();
        List<Usuario> tecnicosDestacados = getTecnicosMasDestacados();

        metrics.put("tecnicosActivos", tecnicosActivos);
        metrics.put("citasActivas", citasActivas);
        metrics.put("totalGanancias", totalGanancias);
        metrics.put("tecnicosMasDestacados", tecnicosDestacados);

        return metrics;
    }

    public int getTecnicosActivos() throws ExecutionException, InterruptedException {
        QuerySnapshot snapshot = firestore.collection("usuarios")
                .whereEqualTo("rol", "TECNICO")
                .get()
                .get();
        return snapshot.size();
    }

    public int getCitasActivas() throws ExecutionException, InterruptedException {
        QuerySnapshot snapshot = firestore.collection("citas")
                .whereEqualTo("estado", "confirmada")
                .get()
                .get();
        return snapshot.size();
    }
    
    public double getTotalGanancias() throws ExecutionException, InterruptedException {
        QuerySnapshot snapshot = firestore.collection("citas")
                .whereEqualTo("estado", "completada")
                .get()
                .get();

        double total = 0.0;
        for (QueryDocumentSnapshot document : snapshot.getDocuments()) {
            Cita cita = document.toObject(Cita.class);
            total += cita.getCostoTotal();
        }
        return total;
    }

    public List<Usuario> getTecnicosMasDestacados() throws ExecutionException, InterruptedException {
        QuerySnapshot citasSnapshot = firestore.collection("citas")
                .whereEqualTo("estado", "completada")
                .get()
                .get();

        // 1. Mapear los documentos a objetos Cita.
        // 2. Agrupar las citas por el ID del técnico.
        // 3. Contar la cantidad de citas por cada técnico.
        Map<String, Long> conteoPorTecnico = citasSnapshot.getDocuments().stream()
                .map(doc -> doc.toObject(Cita.class))
                .collect(Collectors.groupingBy(
                    Cita::getTecnicoId,
                    Collectors.counting()
                ));

        // Ordenar los técnicos por la cantidad de citas completadas y obtener los 3 primeros.
        List<String> topTecnicosIds = conteoPorTecnico.entrySet().stream()
                .sorted(Map.Entry.comparingByValue(Comparator.reverseOrder()))
                .limit(3)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        // Buscar los objetos Usuario de los técnicos destacados por su ID de correo.
        if (topTecnicosIds.isEmpty()) {
            return List.of();
        }
        
        List<Usuario> tecnicosDestacados = firestore.collection("usuarios")
                .whereIn("correo", topTecnicosIds)
                .get()
                .get()
                .toObjects(Usuario.class);
        
        return tecnicosDestacados;
    }
}