package com.backend.servicejc.security;

import com.backend.servicejc.model.Usuario; // Asegúrate de importar tu modelo Usuario
import com.backend.servicejc.service.UsuarioService; // O tu Repository
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UsuarioService usuarioService; // Usamos tu servicio existente para buscar usuarios

    // Este método lo usa Spring Security para el Login
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        try {
            Usuario usuario = usuarioService.getUsuarioByEmail(email); // Necesitas este método en tu UsuarioService
            if (usuario == null) {
                throw new UsernameNotFoundException("Usuario no encontrado con email: " + email);
            }
            return buildUserDetails(usuario);
        } catch (Exception e) {
            throw new UsernameNotFoundException("Error al cargar usuario: " + e.getMessage());
        }
    }

    // Este método lo usa el Filtro JWT para cargar al usuario por ID
    public UserDetails loadUserById(String id) {
        try {
            Usuario usuario = usuarioService.getUsuarioById(id); // Necesitas este método en tu UsuarioService
            if (usuario == null) {
                throw new UsernameNotFoundException("Usuario no encontrado con id: " + id);
            }
            return buildUserDetails(usuario);
        } catch (Exception e) {
            throw new RuntimeException("Error al cargar usuario por ID", e);
        }
    }

  private UserDetails buildUserDetails(Usuario usuario) {
        
        // 1. ROL: Validación simple de String
        String rolSeguro = "USER"; // Valor por defecto
        
        if (usuario.getRol() != null && !usuario.getRol().isEmpty()) {
            // Convertimos a mayúsculas por convención de Spring (opcional pero recomendado)
            rolSeguro = usuario.getRol().toUpperCase(); 
        }

        GrantedAuthority authority = new SimpleGrantedAuthority(rolSeguro);
        Collection<GrantedAuthority> authorities = Collections.singleton(authority);

        // 2. PASSWORD: Evitar nulos
        String passwordSegura = (usuario.getPassword() != null) ? usuario.getPassword() : "";

        return new org.springframework.security.core.userdetails.User(
                usuario.getId(), 
                passwordSegura, 
                authorities
        );
    }
}