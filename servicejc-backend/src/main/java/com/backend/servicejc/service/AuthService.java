package com.backend.servicejc.service;

import com.backend.servicejc.model.AuthResponse;
import com.backend.servicejc.model.LoginDto;
import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.security.JwtTokenProvider;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder; // ✅ NECESARIO
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;

@Service
public class AuthService {

    private final Firestore firestore;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder; // ✅ NECESARIO PARA COMPARAR HASHES

    @Autowired
    public AuthService(Firestore firestore, JwtTokenProvider jwtTokenProvider, PasswordEncoder passwordEncoder) {
        this.firestore = firestore;
        this.jwtTokenProvider = jwtTokenProvider;
        this.passwordEncoder = passwordEncoder;
    }

    // =========================================================================
    // 📝 REGISTRO (CORREGIDO: Usa Correo como ID + Encripta Password)
    // =========================================================================
    public void registerUser(Usuario usuario) throws ExecutionException, InterruptedException {
        // 1. Usar el CORREO como ID del documento (Vital para evitar duplicados y errores 403)
        String userId = usuario.getCorreo(); 
        
        DocumentSnapshot doc = firestore.collection("usuarios").document(userId).get().get();

        if (doc.exists()) {
            throw new RuntimeException("El correo ya está registrado.");
        }

        // 2. Preparar Usuario Seguro
        usuario.setId(userId); // ID = Correo
        
        // 🔐 ENCRIPTAR (Vital)
        String passEncriptada = passwordEncoder.encode(usuario.getContrasena());
        usuario.setContrasena(passEncriptada);

        // 🛡️ ROL STRING (Vital)
        if (usuario.getRol() == null || usuario.getRol().isEmpty()) {
            usuario.setRol("USER");
        }

        // 3. Guardar con .set() (no .add()) para forzar el ID
        firestore.collection("usuarios").document(userId).set(usuario).get();
    }

    // =========================================================================
    // 🔐 LOGIN MANUAL (CORREGIDO: Compara Hash vs Texto)
    // =========================================================================
    public AuthResponse loginUser(LoginDto loginDto) throws ExecutionException, InterruptedException {
        System.out.println("🔵 [LOGIN] Intentando entrar: " + loginDto.getCorreo());

        // 1. Buscar Directamente por ID (Correo) -> Más rápido y seguro
        DocumentSnapshot doc = firestore.collection("usuarios").document(loginDto.getCorreo()).get().get();

        if (!doc.exists()) {
            System.out.println("❌ Usuario no encontrado.");
            throw new RuntimeException("Credenciales inválidas");
        }

        Usuario usuario = doc.toObject(Usuario.class);
        // Asegurar ID
        if (usuario.getId() == null) usuario.setId(doc.getId());

        // 2. VERIFICAR CONTRASEÑA (Encriptada vs Texto Plano)
        // passwordEncoder.matches( "123456", "$2a$10$..." )
        if (!passwordEncoder.matches(loginDto.getContrasena(), usuario.getContrasena())) {
             System.out.println("❌ Contraseña incorrecta (Hash no coincide).");
             throw new RuntimeException("Credenciales inválidas");
        }

        // 3. Generar Token
        // OJO: Aquí 'usuario.getId()' es el CORREO. Eso es lo que irá en el Token.
        Authentication auth = new UsernamePasswordAuthenticationToken(usuario.getId(), null);
        String jwt = jwtTokenProvider.generateToken(auth);

        // 4. Devolver Rol seguro
        String rolResponse = (usuario.getRol() != null) ? usuario.getRol() : "USER";

        System.out.println("🚀 Login Exitoso. Rol: " + rolResponse);
        return new AuthResponse(jwt, rolResponse, usuario.getId());
    }
}