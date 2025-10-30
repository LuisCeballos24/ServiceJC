package com.backend.servicejc.controller;

import com.backend.servicejc.model.Cita;
import com.backend.servicejc.service.CitaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/api/citas")
public class CitaController {

    private final CitaService citaService;

    public CitaController(CitaService citaService) {
        this.citaService = citaService;
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

    @PostMapping
    public ResponseEntity<String> createCita(@RequestBody Cita cita) {
        try {
            citaService.createCita(cita);
            return new ResponseEntity<>("Cita creada exitosamente.", HttpStatus.CREATED);
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