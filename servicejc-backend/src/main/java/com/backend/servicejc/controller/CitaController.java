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
    public ResponseEntity<List<Cita>> getAllCitas() {
        try {
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
}