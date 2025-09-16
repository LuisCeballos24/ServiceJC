package com.backend.servicejc.security;

import com.backend.servicejc.model.Usuario;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import java.util.concurrent.ExecutionException;
import java.util.Collections;
import java.util.List;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private final Firestore firestore;

    @Autowired
    public UserDetailsServiceImpl(Firestore firestore) {
        this.firestore = firestore;
    }

    @Override
    public UserDetails loadUserByUsername(String correo) throws UsernameNotFoundException {
        try {
            // Busca el usuario en Firestore por su correo
            QuerySnapshot querySnapshot = firestore.collection("usuarios")
                .whereEqualTo("correo", correo)
                .get()
                .get();

            List<QueryDocumentSnapshot> documents = querySnapshot.getDocuments();

            if (documents.isEmpty()) {
                throw new UsernameNotFoundException("Usuario no encontrado con el correo: " + correo);
            }

            // Convierte el documento de Firestore a un objeto Usuario
            Usuario usuario = documents.get(0).toObject(Usuario.class);
            
            // Retorna un objeto UserDetails que Spring Security usará
            return new User(
                usuario.getCorreo(),
                usuario.getContrasena(),
                Collections.emptyList() // No usamos roles por ahora
            );
        } catch (InterruptedException | ExecutionException e) {
            throw new UsernameNotFoundException("Error al cargar el usuario: " + correo, e);
        }
    }
}