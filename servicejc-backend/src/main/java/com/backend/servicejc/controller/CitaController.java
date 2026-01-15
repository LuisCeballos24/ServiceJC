package com.backend.servicejc.controller;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.service.CitaService;
import com.backend.servicejc.service.FirebaseStorageService;
// 1. Agregar estos imports para la conversión manual de JSON
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType; // Importante
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
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
    // MÉTODO CORREGIDO PARA RECIBIR FOTO + JSON DESDE FLUTTER
    // -------------------------------------------------------------------------
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> createCita(
            @RequestPart("cita") String citaJson, // 2. Recibimos String en vez de Objeto directo
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        try {
            // 3. Convertir manualmente el String JSON a Objeto Cita
            ObjectMapper mapper = new ObjectMapper();
            // Esto es vital para que las fechas (LocalDate/LocalDateTime) no den error
            mapper.registerModule(new JavaTimeModule()); 
            
            Cita cita = mapper.readValue(citaJson, Cita.class);

            // 4. Lógica de imagen (Igual que antes)
            String imageUrl = null;
            if (file != null && !file.isEmpty()) {
                String path = "citas/" + cita.getUsuarioId() + "/";
                imageUrl = storageService.uploadFile(file, path);
            }

            cita.setImageUrl(imageUrl);

            // 5. Guardar
            citaService.createCita(cita);

            return new ResponseEntity<>("Cita creada exitosamente.", HttpStatus.CREATED);

        } catch (IOException e) {
            e.printStackTrace();
            return new ResponseEntity<>("Error al procesar datos: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            e.printStackTrace();
            return new ResponseEntity<>("Error del servidor: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    // -------------------------------------------------------------------------

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getCitasByUsuarioId(@PathVariable String usuarioId) {
        try {
            List<Cita> citas = citaService.getCitasByUsuarioId(usuarioId);
            return new ResponseEntity<>(citas, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Error al obtener las citas: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')")
    public ResponseEntity<Cita> updateCita(@PathVariable String id, @RequestBody Cita citaDetails) {
        try {
            Cita updatedCita = citaService.updateCita(id, citaDetails);
            return ResponseEntity.ok(updatedCita);
        } catch (RuntimeException e) {
            if (e.getMessage().contains("Cita no encontrada")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
}