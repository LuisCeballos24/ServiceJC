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

import java.util.Date;
import java.util.List;
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
}