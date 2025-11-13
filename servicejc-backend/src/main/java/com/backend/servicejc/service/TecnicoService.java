package com.backend.servicejc.service;

import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.model.Cita;
import com.backend.servicejc.model.Rol;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.CollectionReference;
import com.google.cloud.firestore.DocumentReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.google.cloud.firestore.QuerySnapshot;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.DocumentSnapshot; // Necesario para obtener el estado actual
// ...

import java.util.Date;
import java.util.List;
import java.util.HashMap; // <--- NUEVA IMPORTACIÓN
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service
public class TecnicoService {

    private final Firestore firestore;
    private final BCryptPasswordEncoder passwordEncoder;
    private static final String USUARIOS_COLLECTION = "usuarios"; // Constante para el nombre de la colección

    @Autowired
    public TecnicoService(Firestore firestore, BCryptPasswordEncoder passwordEncoder) {
        this.firestore = firestore;
        this.passwordEncoder = passwordEncoder;
    }

    public String crearTecnico(Usuario tecnico) throws ExecutionException, InterruptedException {
        CollectionReference usuariosCollection = firestore.collection("usuarios");
        String encodedPassword = passwordEncoder.encode(tecnico.getContrasena());
        tecnico.setContrasena(encodedPassword);

        usuariosCollection.document(tecnico.getCorreo()).set(tecnico).get();
        return "Técnico creado exitosamente";
    }

   public List<Usuario> obtenerTecnicos() throws ExecutionException, InterruptedException {
        // Consulta la colección 'usuarios' donde el campo 'rol' es igual a 'TECNICO'
        QuerySnapshot querySnapshot = firestore.collection(USUARIOS_COLLECTION)
                .whereEqualTo("rol", "TECNICO")
                .get()
                .get();

        // Mapea los documentos resultantes a objetos Usuario
        return querySnapshot.getDocuments().stream()
                .map(document -> document.toObject(Usuario.class))
                .collect(Collectors.toList());
    }

    public void eliminarTecnico(String tecnicoId) throws ExecutionException, InterruptedException {
        CollectionReference usuariosCollection = firestore.collection("usuarios");
        usuariosCollection.document(tecnicoId).delete().get();
    }
    
    // Nuevo método para reasignar el horario de una cita
    public void reasignarHorario(String citaId, String nuevoTecnicoId, Date nuevaFechaHora) throws ExecutionException, InterruptedException {
        DocumentReference citaRef = firestore.collection("citas").document(citaId);
        
        // Actualiza los campos de fecha, hora y el técnico asignado
        citaRef.update("fechaHora", nuevaFechaHora, "tecnicoId", nuevoTecnicoId).get();
    }

    public Usuario updateTecnico(Usuario tecnicoDetails) throws ExecutionException, InterruptedException {
        // Asumimos que tecnicoDetails.getId() contiene el DocumentId del usuario en Firestore.
        DocumentReference docRef = firestore.collection(USUARIOS_COLLECTION).document(tecnicoDetails.getId());
        
        DocumentSnapshot snapshot = docRef.get().get();
        if (!snapshot.exists()) {
            throw new RuntimeException("Técnico no encontrado con ID: " + tecnicoDetails.getId());
        }

        // 1. Construir mapa de actualizaciones (solo incluye campos no nulos)
        Map<String, Object> updates = new HashMap<>();
        
        if (tecnicoDetails.getNombre() != null) {
            updates.put("nombre", tecnicoDetails.getNombre());
        }

        if (tecnicoDetails.getCorreo() != null) {
            updates.put("correo", tecnicoDetails.getCorreo());
        }
        
        // 2. Manejar la Contraseña (solo se actualiza si se envía una nueva)
        if (tecnicoDetails.getContrasena() != null && !tecnicoDetails.getContrasena().isEmpty()) {
            String encodedPassword = passwordEncoder.encode(tecnicoDetails.getContrasena());
            updates.put("contrasena", encodedPassword);
        }

        // 3. Aplicar actualizaciones
        if (!updates.isEmpty()) {
            docRef.update(updates).get();
        } else {
            // Si no hay campos para actualizar, devuelve el objeto actual
            return snapshot.toObject(Usuario.class);
        }

        // 4. Devolver el objeto Usuario actualizado y enriquecido
        DocumentSnapshot updatedSnapshot = docRef.get().get();
        return updatedSnapshot.toObject(Usuario.class);
    }
}