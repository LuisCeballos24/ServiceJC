package com.backend.servicejc.controller;

import com.backend.servicejc.model.LoginDto;
import com.backend.servicejc.model.Usuario;
import com.backend.servicejc.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.backend.servicejc.model.AuthResponse; // <--- AGREGAR ESTA LÍNEA

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<String> registerUser(@RequestBody Usuario usuario) {
        try {
            authService.registerUser(usuario);
            return new ResponseEntity<>("Usuario registrado exitosamente.", HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> loginUser(@RequestBody LoginDto loginDto) {
        try {
            // CORRECCIÓN: Llamamos al servicio y devolvemos el objeto AuthResponse completo
            AuthResponse response = authService.loginUser(loginDto);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            // Manejo de errores
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
    }
}