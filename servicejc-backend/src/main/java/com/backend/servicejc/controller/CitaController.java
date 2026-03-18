package com.backend.servicejc.controller;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.service.CitaService;
import com.backend.servicejc.service.FirebaseStorageService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
// 1. 👇 ESTE ES EL IMPORT QUE FALTABA
import org.springframework.security.core.Authentication; 
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Enumeration;
import java.util.List;

@RestController
@RequestMapping("/api/citas")
public class CitaController {

    private final CitaService citaService;
    private final FirebaseStorageService storageService;

    public CitaController(CitaService citaService, FirebaseStorageService storageService) {
        this.citaService = citaService;
        this.storageService = storageService;
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('ADMINISTRATIVO', 'TECNICO')")
    public ResponseEntity<List<Cita>> getAllCitas() {
        try {
            List<Cita> citas = citaService.getAllCitas();
            return ResponseEntity.ok(citas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/tecnico/{tecnicoId}")
    @PreAuthorize("hasAnyAuthority('ADMINISTRATIVO', 'TECNICO')")
    public ResponseEntity<?> getCitasByTecnicoId(@PathVariable String tecnicoId) {
        try {
            List<Cita> citas = citaService.getCitasByTecnicoId(tecnicoId);
            return new ResponseEntity<>(citas, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Error al obtener las citas del técnico: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // -------------------------------------------------------------------------
    // MÉTODO PARA CREAR CITA (CON FOTO + JSON)
    // -------------------------------------------------------------------------
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> createCita(
            @RequestPart("cita") String citaJson,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule()); 
            
            Cita cita = mapper.readValue(citaJson, Cita.class);

            String imageUrl = null;
            if (file != null && !file.isEmpty()) {
                String path = "citas/" + cita.getUsuarioId() + "/";
                imageUrl = storageService.uploadFile(file, path);
            }

          cita.setImageUrl(imageUrl);
            // Guardamos el ID que nos devuelve el servicio
            String nuevaCitaId = citaService.createCita(cita);

            // Devolvemos el ID real a Flutter
            return new ResponseEntity<>(nuevaCitaId, HttpStatus.CREATED);

        } catch (IOException e) {
            e.printStackTrace();
            return new ResponseEntity<>("Error al procesar datos: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>("Error del servidor: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
   @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getCitasByUsuarioId(@PathVariable String usuarioId, 
                                                 Authentication authentication,
                                                 HttpServletRequest request) { // 🟢 AGREGAMOS EL REQUEST
        try {
            System.out.println("------------------------------------------");
            System.out.println("🕵️ INSPECCIÓN DE PAQUETE ENTRANTE");
            
            // 1. IMPRIMIR TODOS LOS HEADERS QUE LLEGAN
            Enumeration<String> headerNames = request.getHeaderNames();
            boolean hayToken = false;
            
            while (headerNames.hasMoreElements()) {
                String key = headerNames.nextElement();
                String value = request.getHeader(key);
                System.out.println("📨 Header: " + key + " = " + value);
                
                if (key.equalsIgnoreCase("Authorization")) {
                    hayToken = true;
                }
            }
            System.out.println("------------------------------------------");

            // 2. DIAGNÓSTICO
            if (!hayToken) {
                System.out.println("❌ ERROR FATAL: El header 'Authorization' NO LLEGÓ.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Tu App no envió el token.");
            }

            if (authentication == null) {
                System.out.println("⚠️ ALERTA: Llegó el header Authorization, pero el Token es inválido o expiró.");
                // Como tenemos permitAll() en security, dejamos pasar para ver si al menos devuelve las citas
            } else {
                System.out.println("✅ Autenticación Exitosa: " + authentication.getName());
            }

            // 3. RETORNAR CITAS (Mantenemos la lógica que ya funcionaba)
            List<Cita> citas = citaService.getCitasByUsuarioId(usuarioId);
            return ResponseEntity.ok(citas);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error: " + e.getMessage());
        }
    }
    // -------------------------------------------------------------------------
    // MÉTODO PARA EDITAR CITA (ADMIN O DUEÑO)
    // -------------------------------------------------------------------------
    @PutMapping("/{id}")
    // 🟢 1. REACTIVAMOS EL FILTRO DE ROLES
    @PreAuthorize("hasAnyAuthority('ADMINISTRATIVO', 'USUARIO_FINAL')") 
    public ResponseEntity<?> updateCita(@PathVariable String id, 
                                        @RequestBody Cita citaDetails,
                                        Authentication authentication) { 
        try {
            Cita citaExistente = citaService.getCitaById(id); 

            if (citaExistente == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Cita no encontrada");
            }

            // 🟢 2. REACTIVAMOS LA LÓGICA DE PROPIEDAD
            // Obtenemos quién está intentando entrar
            String usuarioLogueadoId = authentication.getName(); 
            
            // Verificamos si es admin
            boolean esAdmin = authentication.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ADMINISTRATIVO"));

            // REGLA: Si NO es admin Y el ID de la cita no coincide con el suyo -> FUERA
            if (!esAdmin && !citaExistente.getUsuarioId().equals(usuarioLogueadoId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("No tienes permiso para modificar una cita que no te pertenece.");
            }

            // Si pasa, actualizamos
            Cita updatedCita = citaService.updateCita(id, citaDetails);
            return ResponseEntity.ok(updatedCita);

        } catch (RuntimeException e) {
             // ... manejo de errores ...
             return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        } catch (Exception e) {
             return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
}