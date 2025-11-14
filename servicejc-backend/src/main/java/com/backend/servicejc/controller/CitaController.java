package com.backend.servicejc.controller;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.service.CitaService;
import org.springframework.http.HttpStatus;
import org.springframework.web.multipart.MultipartFile;
import com.backend.servicejc.service.FirebaseStorageService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import java.io.IOException;

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
    // MODIFICADO: Cambiar tipo de retorno
    public ResponseEntity<List<Cita>> getAllCitas() { 
        try {
            // Llama al servicio, que ahora devuelve DTOs
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
            List<Cita> citas = citaService.getCitasByTecnicoId(tecnicoId); // Llamar al nuevo método
            return new ResponseEntity<>(citas, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>("Error al obtener las citas del técnico: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<String> createCita(
        @RequestPart("cita") Cita cita, // Datos de la cita (JSON)
        @RequestPart(value = "file", required = false) MultipartFile file // El archivo de la foto
    ) {
        try {
            String imageUrl = null;
            
            // 1. Si existe un archivo, subirlo a Firebase Storage
            if (file != null && !file.isEmpty()) {
                // Definimos la carpeta de subida
                String path = "citas/" + cita.getUsuarioId() + "/";
                imageUrl = storageService.uploadFile(file, path);
            }
            
            // 2. Asignar el URL obtenido (o null) al modelo antes de guardar en Firestore
            cita.setImageUrl(imageUrl);
            
            // 3. Guardar la cita en Firestore (con el URL de la imagen)
            citaService.createCita(cita);
            
            return new ResponseEntity<>("Cita creada exitosamente.", HttpStatus.CREATED);
        } catch (IOException e) {
            return new ResponseEntity<>("Error I/O al procesar la imagen: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<?> getCitasByUsuarioId(@PathVariable String usuarioId) {
        try {
            List<Cita> citas = citaService.getCitasByUsuarioId(usuarioId);
            return new ResponseEntity<>(citas, HttpStatus.OK);
        } catch (Exception e) {
            // Maneja cualquier error que ocurra al obtener las citas
            return new ResponseEntity<>("Error al obtener las citas: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ADMINISTRATIVO')") // Solo administradores pueden actualizar citas
    public ResponseEntity<Cita> updateCita(@PathVariable String id, @RequestBody Cita citaDetails) {
        try {
            // Llama al método de servicio que maneja la lógica de actualización
            Cita updatedCita = citaService.updateCita(id, citaDetails); 
            return ResponseEntity.ok(updatedCita);
        } catch (RuntimeException e) {
             // Manejar si la cita no fue encontrada, asumiendo que el servicio lanza una RuntimeException
            if (e.getMessage().contains("Cita no encontrada")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        } catch (Exception e) {
             // Manejar ExecutionException, InterruptedException y otros errores
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }
}