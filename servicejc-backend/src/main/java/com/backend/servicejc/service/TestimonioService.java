package com.backend.servicejc.service;

import com.backend.servicejc.model.TestimonioModel;
import com.google.cloud.firestore.Firestore;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class TestimonioService {

    private final Firestore firestore;
    // ✅ Constante para el nombre de la colección
    private static final String TESTIMONIOS_COLLECTION = "testimonios";

    @Autowired
    public TestimonioService(Firestore firestore) {
        this.firestore = firestore;
    }

    // =================================================================================
    // 📖 MÉTODOS DE LECTURA (Estilo TecnicoService)
    // =================================================================================

    public List<TestimonioModel> getTestimoniosDestacados() throws ExecutionException, InterruptedException {
        // Consulta la colección usando la constante
        QuerySnapshot querySnapshot = firestore.collection(TESTIMONIOS_COLLECTION)
                .whereEqualTo("destacado", true)
                .get()
                .get(); // Bloqueo síncrono

        // Mapea los documentos resultantes a objetos TestimonioModel
        return querySnapshot.getDocuments().stream()
                .map(document -> {
                    TestimonioModel t = document.toObject(TestimonioModel.class);
                    // Aseguramos que el ID venga del documento
                    t.setId(document.getId());
                    return t;
                })
                .collect(Collectors.toList());
    }

    // =================================================================================
    // 🌱 MÉTODOS DE POBLADO (SEEDING)
    // =================================================================================

    public void seedTestimonios() throws ExecutionException, InterruptedException {
        CollectionReference testimoniosRef = firestore.collection(TESTIMONIOS_COLLECTION);

        // 1. Verificar si ya existen datos (Limit 1 es más eficiente)
        QuerySnapshot snapshot = testimoniosRef.limit(1).get().get();

        if (!snapshot.isEmpty()) {
            System.out.println("⚠️ La colección '" + TESTIMONIOS_COLLECTION + "' ya tiene datos. Omitiendo seed.");
            return;
        }

        System.out.println("🚀 Insertando testimonios reales en " + TESTIMONIOS_COLLECTION + "...");

        List<TestimonioModel> lista = new ArrayList<>();

        // --- DATOS DUROS ---
        // ⚠️ NOTA: Agregué la 'L' al número 5 (ej: 5L) para que sea un Long y coincida
        // con el Modelo.
        lista.add(new TestimonioModel(null, "Carlos Méndez",
                "El técnico llegó puntual y reparó mi aire acondicionado en menos de una hora. El precio fue justo y dejaron todo limpio. ¡Muy recomendados!",
                5L, true));
        lista.add(new TestimonioModel(null, "Sofía Rodríguez",
                "Contraté la limpieza profunda para mi apartamento antes de mudarme y quedó impecable. Se nota el profesionalismo del equipo.",
                5L, true));
        lista.add(new TestimonioModel(null, "Jorge L.",
                "Tenía una fuga urgente en el baño un domingo. Respondieron rápido y solucionaron el problema evitando que se dañara el piso. Servicio 10/10.",
                5L, true));
        lista.add(new TestimonioModel(null, "Ana Paula V.",
                "El servicio de bartender para mi cumpleaños fue un éxito total. Los cócteles estaban deliciosos y el trato a mis invitados fue excelente.",
                5L, true));
        lista.add(new TestimonioModel(null, "Roberto G.",
                "Hicieron un trabajo de pintura exterior en mi casa y quedó como nueva. Me asesoraron con los colores y terminaron antes de lo previsto.",
                5L, true));
        lista.add(new TestimonioModel(null, "Luisa Fernanda",
                "Me ayudaron a instalar unas lámparas y soportes de TV. Fue rápido, seguro y el personal muy amable.",
                5L, true));

        // Insertar en Firestore
        for (TestimonioModel t : lista) {
            // Usamos .add() para que Firestore genere el ID, y .get() para esperar a que
            // termine
            testimoniosRef.add(t).get();
        }

        System.out.println("✅ Testimonios insertados correctamente.");
    }

    public String guardarTestimonio(TestimonioModel testimonio) throws ExecutionException, InterruptedException {
        
        // 1. Agregar a la colección
        ApiFuture<DocumentReference> future = firestore.collection(TESTIMONIOS_COLLECTION).add(testimonio);
        
        // 2. .get() BLOQUEA hasta que Firestore confirme que se guardó.
        // Esto es vital para que el Controller sepa si falló o no.
        DocumentReference resultado = future.get();
        
        // 3. Devolvemos el ID generado por si lo quieres usar
        return resultado.getId();
    }
}