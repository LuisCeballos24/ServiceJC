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
        String userId = usuario.getCorreo(); 
        
        DocumentSnapshot doc = firestore.collection("usuarios").document(userId).get().get();

        if (doc.exists()) {
            throw new RuntimeException("El correo ya está registrado.");
        }

        // Preparar Usuario Seguro
        usuario.setId(userId); 
        String passEncriptada = passwordEncoder.encode(usuario.getContrasena());
        usuario.setContrasena(passEncriptada);

        if (usuario.getRol() == null || usuario.getRol().isEmpty()) {
            usuario.setRol("USER");
        }

        // 👇 NUEVA LÓGICA: INICIALIZAR BILLETERA Y MEMBRESÍA
        usuario.setWalletBalance(0.0); // Inicia con $0.00
        usuario.setIsPremium(false);   // Inicia como usuario normal

        // Generar Código de Referido (Ej: Las primeras 4 letras del nombre + 4 números aleatorios)
        String baseName = usuario.getNombre().replaceAll("\\s+", "").toUpperCase();
        if (baseName.length() > 4) {
            baseName = baseName.substring(0, 4);
        }
        int randomNum = (int)(Math.random() * 9000) + 1000; // Número entre 1000 y 9999
        usuario.setCodigoReferido(baseName + randomNum);

        // Guardar en Firestore
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